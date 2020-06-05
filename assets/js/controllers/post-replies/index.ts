import { Controller } from "stimulus"

export const name = "post-replies"

export default class extends Controller {
  static targets = ["list"]

  addReply({detail: reply}) {
    this.listTarget.insertAdjacentHTML("beforeend", reply)
  }
}
