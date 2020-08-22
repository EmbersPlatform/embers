import { Component } from "../component";
import i18n from "~js/lib/gettext";

export default class extends Component(HTMLElement) {
  static component = "LoadingIndicator";

  static tagName = "element";

  loading_text: string;

  oninit() {
    this.loading_text = this.dataset.loadingText || i18n.gettext("Loading...");
    this.hide();
    this.textContent = this.loading_text;
  }

  show() {
    this.classList.remove("hidden");
  }

  hide() {
    this.classList.add("hidden");
  }
}
