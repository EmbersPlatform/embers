import { Controller } from "stimulus";

export const name = "shareable"

export default class extends Controller {
  static targets = ["dialog"];

  showDialog() {
    this.dialogTarget.open();
  }
}
