import { BaseController } from "~js/lib/controller";

import * as Posts from "~js/lib/posts";

export const name = "comments"

enum States {Idle, Loading, Finished};

export default class extends BaseController {
  static targets = ["commentList", "load_more_button"];

  element: HTMLElement;

  state = States.Idle;
  post_id: string;
  next: string;
  last_page: boolean;

  connect() {
    this.state = States.Idle;
    this.post_id = this.element.dataset.post_id;
    this.next = this.element.dataset.next;
    this.last_page = (this.element.dataset.last_page == "true");
  }

  handleEvent(event) {
    switch (event.type) {
      case "publish": {
        this.addComment(event.detail)
      }
    }
  }

  addComment(comment) {
    this.get_target("commentList").insertAdjacentHTML("beforeend", comment)
  }

  onpublish({ detail: comment }) {
    this.addComment(comment)
  }

  async load_more() {
    if(this.state !== States.Idle) return;

    this.state = States.Loading;
    this.get_target<HTMLButtonElement>("load_more_button").disabled = true;

    const res = await Posts.get_replies(this.post_id, {after: this.next, order: "asc", limit: 10, as_thread: true, replies: 2});
    switch(res.tag) {
      case "Success": {
        const page = res.value;
        this.next = page.next;
        this.last_page = page.last_page;
        this.addComment(page.body);
        break;
      }
      case "Error": {
        console.error(res.value);
        break;
      }
      case "NetworkError": {
        console.error("Could not connect with server.")
        break;
      }
    }

    this.state = this.last_page ? States.Finished : States.Idle;
    this.get_target<HTMLButtonElement>("load_more_button").disabled = false;
    if(this.state === States.Finished)
      this.get_target<HTMLButtonElement>("load_more_button").remove();
  }
}
