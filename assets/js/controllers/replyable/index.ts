import { BaseController } from "~js/lib/controller";

import * as Posts from "~js/lib/posts";
import * as Window from "~js/lib/utils/window";
import PostEditor from "~js/components/editor";
import LoadingIndicator from "~js/components/loading_indicator";

export const name = "replyable";

enum States {Idle, Loading, Finished}

export default class extends BaseController {
  static targets = ["replyEditor", "loadMoreButton", "insertionPoint", "loadingIndicator"]

  state = States.Idle;
  next: string;
  first_load: boolean;
  last_page: boolean;

  connect() {
    this.next = this.element.dataset.next;
    this.first_load = true;
  }

  reply(event) {
    if(!this.has_target("replyEditor")) return;
    this.get_target<PostEditor>("replyEditor").show();
    let author =
      event.target.closest("button").dataset.author;
    this.get_target<PostEditor>("replyEditor").addReply(author);
  }

  async load_older_replies() {
    if(!this.has_target("insertionPoint")) return;
    if(this.state === States.Idle) {
      this.state = States.Loading;
      this.get_target("loadMoreButton").classList.add("hidden");
      this.get_target<LoadingIndicator>("loadingIndicator").show();

      const params: Posts.GetRepliesParams = { before: this.next, limit: 10, order: "desc" }
      if(this.first_load)
        params.skip_first = true;

      const res = await Posts.get_replies(this.element.dataset.id, params);
      switch(res.tag) {
        case "Success": {
          const {next, last_page, body} = res.value;
          this.first_load = false;
          this.next = next;
          this.last_page = last_page;
          this.get_target("insertionPoint").insertAdjacentHTML("afterend", body);
          Window.scroll_into_view(this.get_target("insertionPoint"));
          break;
        }
        case "Error": {
          console.error("Error retrieving replies", res.value);
          break;
        }
        case "NetworkError": {
          console.error("Could not connect to server");
        }
      }

      this.state = (this.last_page) ? States.Finished : States.Idle;
      this.get_target<LoadingIndicator>("loadingIndicator").hide();

      switch(this.state) {
        case States.Idle: {
          this.get_target("loadMoreButton").classList.remove("hidden");
          break;
        }
        case States.Finished: {
          this.get_target("loadMoreButton").remove();
          break;
        }
      }
    }
  }
}
