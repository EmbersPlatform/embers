import { Controller } from "stimulus";
import union from "~js/lib/utils/union";

import * as Posts from "~js/lib/posts";
import * as Window from "~js/lib/utils/window";

export const name = "replyable";

const States = union("States", {
  Idle: [],
  Loading: [],
  Finished: []
})

export default class extends Controller {
  static targets = ["replyEditor", "loadMoreButton", "insertionPoint", "loadingIndicator"]

  connect() {
    this.state = States.Idle;
    this.next = this.element.dataset.next;
    this.first_load = true;
  }

  reply(event) {
    if(!this.hasReplyEditorTarget) return;
    this.replyEditorTarget.show();
    let author =
      event.target.closest("button").dataset.author;
    this.replyEditorTarget.addReply(author);
  }

  async load_older_replies() {
    if(!this.hasInsertionPointTarget) return;
    this.state.match({
      Idle: async () => {
        this.state = States.Loading;
        this.loadMoreButtonTarget.classList.add("hidden");
        this.loadingIndicatorTarget.show();
        const params = { before: this.next, limit: 10, order: "desc" }
        if(this.first_load)
          params.skip_first = true;

        const response = await Posts.get_replies(this.element.dataset.id, params)

        response.match({
          Success: ({ last_page, next, body }) => {
            this.first_load = false;
            this.next = next;
            this.last_page = last_page;
            this.insertionPointTarget.insertAdjacentHTML("afterend", body);
            Window.scroll_into_view(this.insertionPointTarget);
          },
          Error: errors => console.error("Error retrieving replies", errors),
          NetworkError: () => console.error("Could not connect to server")
        })

        this.state = (this.last_page) ? States.Finished : States.Idle;
        this.loadingIndicatorTarget.hide();

        this.state.match({
          Idle: () => {
            this.loadMoreButtonTarget.classList.remove("hidden")
          },
          Loading: () => {},
          Finished: () => {
            this.loadMoreButtonTarget.remove();
          }
        })
      },
      Loading: () => {},
      Finished: () => {}
    })
  }
}
