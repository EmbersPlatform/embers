import { Controller } from "stimulus"

import union from "/js/lib/utils/union";
import * as Posts from "/js/lib/posts";

export const name = "comments"

const States = union("States", {
  Idle: [],
  Loading: [],
  Finished: []
})

export default class extends Controller {
  static targets = ["commentList", "load_more_button"]

  connect() {
    this.state = States.Idle;
    this.post_id = this.element.dataset.post_id;
    this.next = this.element.dataset.next;
    this.last_page = this.element.dataset.last_page;
  }

  handleEvent(event) {
    switch (event.type) {
      case "publish": {
        this.addComment(event.detail)
      }
    }
  }

  addComment(comment) {
    this.commentListTarget.insertAdjacentHTML("beforeend", comment)
  }

  onpublish({ detail: comment }) {
    this.addComment(comment)
  }

  async load_more() {
    console.log("load more comments!")
    if(!States.Idle.is(this.state)) return;

    this.states = States.Loading;
    this.load_more_buttonTarget.disabled = true;

    const res = await Posts.get_replies(this.post_id, {after: this.next, order: "asc", limit: 10, as_thread: true, replies: 2});
    res.match({
      Success: page => {
        this.next = page.next;
        this.last_page = page.last_page;
        this.addComment(page.body);


      },
      Error: console.error,
      NetworkError: console.error
    })

    this.state = this.last_page ? States.Finished : States.Idle;
    this.load_more_buttonTarget.disabled = false;
    if(States.Finished.is(this.state))
          this.load_more_buttonTarget.remove();
  }
}
