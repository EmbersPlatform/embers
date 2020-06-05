import { BaseController } from "~js/lib/controller"

import * as Posts from "~js/lib/posts";
import type ModalDialog from "~js/components/dialog";

export const name = "reply"

export default class extends BaseController {
  static targets = ["deleteDialog", "reactionsDialog", "reportDialog"]

  confirm_delete() {
    if(this.has_target("deleteDialog"))
    this.get_target<ModalDialog>("deleteDialog").showModal();
  }


  async delete() {
    const res = await Posts.delet(this.element.dataset.id)
    res.match({
      Success: () => {
        this.element.remove();
        this.get_target<ModalDialog>("deleteDialog").close();
      },
      Error: err => {
        alert("Hubo un error al borrar el post")
      },
      NetworkError: () => {
        alert("Hubo un error al conectar con el servidor")
      }
    })
  }

  show_reactions_modal() {
    console.log("show reactions modal")
    if(this.has_target("reactionsDialog"))
      this.get_target<ModalDialog>("reactionsDialog").showModal();
  }

  show_report_modal() {
    if(this.has_target("reportDialog"))
      this.get_target<ModalDialog>("reportDialog").showModal();
  }
}
