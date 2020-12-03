import { html } from "uhtml";
import { show_dialog } from "~js/managers/dialog";
import { ref } from "./component"

export type Tag = {id: string, name: string, description: string}

customElements.define("emb-show-tag-page", class extends HTMLElement{

  tag: Tag;

  connectedCallback() {
    setTimeout(() => {
      this.tag = JSON.parse(this.dataset.tag);
      ref(this).editBtn.addEventListener("click", this.show_edit_dialog);
    })
  }

  disconnectedCallback(){
    ref(this).editBtn.removeEventListener("click", this.show_edit_dialog);
  }

  show_edit_dialog = () => {
    show_dialog((_dialog, close_dialog) => {
      return html`<emb-update-tag .tag=${this.tag} onupdate=${close_dialog} oncancel=${close_dialog}/>`
    });
  }
}, {extends: "main"})
