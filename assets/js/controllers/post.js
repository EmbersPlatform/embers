import { Controller } from "stimulus"

import * as Posts from "#/lib/posts";

export const name = "post"

export default class extends Controller {
  static targets = ["deleteDialog", "reactionsDialog", "reportDialog"]

  confirm_delete() {
    if(this.hasDeleteDialogTarget)
      this.deleteDialogTarget.showModal();
  }

  async delete() {
    const res = await Posts.delet(this.element.dataset.id)
    res.match({
      Success: () => {
        this.element.remove();
        this.deleteDialogTarget.close();
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
    if(this.hasReactionsDialogTarget)
      this.reactionsDialogTarget.showModal();
  }

  show_report_modal() {
    if(this.hasReportDialogTarget)
      this.reportDialogTarget.showModal();
  }
}
