import { html } from "uhtml";
import { show_dialog } from "~js/managers/dialog";
import "./change-password-form";

customElements.define(
  "emb-change-password-field",
  class extends HTMLElement {
    connectedCallback() {
      this.addEventListener("click", this);
    }

    handleEvent(event) {
      const { target } = event;
      switch (target.dataset.action) {
        case "show_modal": {
          this.show_modal();
          break;
        }
      }
    }

    show_modal = () => {
      show_dialog(
        (_dialog, close) => html`
          <emb-change-password-form oncancel=${close} />
        `
      );
    };
  }
);
