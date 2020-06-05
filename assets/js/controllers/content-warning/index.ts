import { BaseController } from "~js/lib/controller";

import i18n from "~js/lib/gettext";

export const name = "content-warning"

export default class extends BaseController {
  static targets = ["button"]

  show_text: string
  hide_text: string

  connect() {
    if(this.has_target("button")) {
      const button = this.get_target("button")
      this.show_text = button.dataset.show_text || i18n.gettext("Show");
      this.hide_text = button.dataset.hide_text || i18n.gettext("Hide");
    }
  }

  toggle() {
    if(!this.element.hasAttribute("nsfw")) {
      this.element.setAttribute("nsfw", "");
      this.get_target("button").innerHTML = this.show_text;
    } else {
      this.element.removeAttribute("nsfw");
      this.get_target("button").innerHTML = this.hide_text;
    }
  }
}
