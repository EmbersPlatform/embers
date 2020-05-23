import { Controller } from "stimulus";

import i18n from "#/lib/gettext";

export const name = "content-warning"

export default class extends Controller {
  static targets = ["button"]

  connect() {
    if(this.hasButtonTarget) {
      this.show_text = this.buttonTarget.dataset.show_text || i18n.gettext("Show");
      this.hide_text = this.buttonTarget.dataset.hide_text || i18n.gettext("Hide");
    }
  }

  toggle() {
    if(!this.element.hasAttribute("nsfw")) {
      this.element.setAttribute("nsfw", "");
      this.buttonTarget.innerHTML = this.show_text;
    } else {
      this.element.removeAttribute("nsfw");
      this.buttonTarget.innerHTML = this.hide_text;
    }
  }
}
