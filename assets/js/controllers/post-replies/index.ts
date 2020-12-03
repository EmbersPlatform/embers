import { BaseController } from "~js/lib/controller"

export const name = "post-replies"

export default class extends BaseController {
  static targets = ["list"]

  addReply({detail: reply}) {
    this.get_target("list").insertAdjacentHTML("beforeend", reply)
  }
}
