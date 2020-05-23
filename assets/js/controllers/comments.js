import { Controller } from "stimulus"

export const name = "comments"

export default class extends Controller {
  static targets = ["commentList"]

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
}
