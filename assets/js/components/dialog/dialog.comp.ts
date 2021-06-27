// @ts-check
import { html, ref } from "heresy";

import { Component } from "../component";

/**
 * Provides a general purpose `<modal-dialog>` component leveraging native
 * `<dialog>` element, thus sharing it's accesible behavior.
 * As `<dialog>` is not natively supported on all browsers, custom elements
 * bultin extends can't be used with them.
 */
export default class ModalDialog extends Component(HTMLElement) {
  static component = "ModalDialog";

  static tagName = "element";

  static booleanAttributes = ["focusable"];
  static mappedAttributes = ["opened"];

  opened = false
  focusable

  dialog
  _contents

  oninit() {
    this.dialog = ref();

    this.classList.add("custom-dialog");

    // See https://github.com/WebReflection/heresy/issues/26#issuecomment-596376596_
    this._contents = [].slice.call(this.children);
  }

  /**
   * Displays the modal dialog with an overlay.
   */
  showModal() {
    this.opened = true;
    setTimeout(() => this.dialog.current.showModal());
  }

  /**
   * Closes the modal dialog.
   */
  close() {
    this.opened = false;
    this.dialog.current.close();
  }

  onopened() {
    this.setAttribute("open", `${this.opened}`);
    this.render();
  }

  render_dialog(contents) {
    const onclose = () => {
      this.opened = false;
      this.dispatch("close");
    }
    const oncancel = () => {
      this.dispatch("cancel");
    }
    const close = () => this.close();

    return html`
      <dialog ref=${this.dialog} oncancel=${oncancel} onclose=${onclose} tabindex=${this.focusable ? -1 : null}>
        <dialog-backdrop onclick=${close}></dialog-backdrop>
        <dialog-box> ${contents} </dialog-box>
      </dialog>
    `;
  }

  render() {
    this.html`${this.render_dialog(this._contents)}`;
  }
};
