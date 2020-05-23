import { html, ref } from "heresy";

import { Base } from "#/components/component";

export default {
  ...Base,
  name: "ModalDialog",
  extends: "element",

  booleanAttributes: ["focusable"],
  mappedAttributes: ["opened"],

  oninit() {
    this.dialog = ref();

    this.classList.add("custom-dialog");

    // See https://github.com/WebReflection/heresy/issues/26#issuecomment-596376596_
    this._contents = [].slice.call(this.children);
  },

  showModal() {
    this.opened = true;
    this.dialog.current.showModal();
  },

  close() {
    this.opened = false;
    this.dialog.current.close();
  },

  onopened() {
    this.setAttribute("open", this.opened);
    this.render();
  },

  oncancel() {
    this.dispatch("cancel");
  },

  onclose() {
    this.opened = false;
    this.dispatch("close");
  },

  render_dialog(contents) {
    const close = () => this.close();

    return html`
      <dialog
        ref=${this.dialog}
        oncancel=${this}
        onclose=${this}
        tabindex=${this.focusable ? -1 : null}
      >
        ${
          this.opened
            ? html`
                <dialog-backdrop onclick=${close}></dialog-backdrop>
              `
            : ``
        }
        <dialog-box> ${contents} </dialog-box>
      </dialog>
    `;
  },

  render() {
    this.html`${this.render_dialog(this._contents)}`;
  }
};
