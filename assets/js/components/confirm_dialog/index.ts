// @ts-check

import { html } from "heresy";

import ModalDialog from "../dialog";

import { gettext } from "~js/lib/gettext";

export default class ConfirmDialog extends ModalDialog {
  static component = "ConfirmDialog";
  static mappedAttributes = [...ModalDialog.mappedAttributes, "disabled"];

  disabled: boolean
  accept_text: string
  cancel_text: string

  oninit() {
    super.oninit();
    this.accept_text = this.dataset.acceptText || gettext("Accept");
    this.cancel_text = this.dataset.cancelText || gettext("Cancel");
  }

  accept() {
    this.dispatch("accept");
    this.close();
  }

  ondisabled() {
    this.render();
  }

  render() {
    const content = html`
      ${this._contents}
      <footer>
        <button
          class="button"
          onclick=${() => this.close()}
        >${this.cancel_text}</button>
        <button
          class="button danger"
          onclick=${() => this.accept()}
          disabled=${this.disabled}
        >${this.accept_text}</button>
      </footer>
    `
    this.html`
      ${this.render_dialog(content)}
    `;
  }
};
