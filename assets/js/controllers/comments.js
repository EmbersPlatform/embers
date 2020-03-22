import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["editor", "commentList"]

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

  connect() {
    this.editorTarget.addEventListener("publish", this)
  }

  disconnect() {
    this.editorTarget.removeEventListener("publish", this)
  }
}
