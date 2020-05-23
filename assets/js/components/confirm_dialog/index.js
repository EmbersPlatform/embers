import { html } from "heresy";

import ModalDialog from "../dialog";

import i18n from "#/lib/gettext";

export default {
  ...ModalDialog,
  name: "ConfirmDialog",

  oninit() {
    ModalDialog.oninit.apply(this);

    this.accept_text = this.dataset.acceptText || i18n.gettext("Accept");
    this.cancel_text = this.dataset.cancelText || i18n.gettext("Cancel");
  },

  accept() {
    this.dispatch("accept");
    this.close();
  },

  render() {
    this.html`
      ${this.render_dialog(html`
        ${this._contents}
        <footer>
          <button class="button" onclick=${() => this.close()}>${this.cancel_text}</button>
          <button class="button danger" onclick=${() => this.accept()}>${this.accept_text}</button>
        </footer>
      `)}
    `;
  }
};
