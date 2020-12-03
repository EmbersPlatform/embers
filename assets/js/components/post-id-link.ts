import { html, render } from "uhtml";
import { gettext } from "~js/lib/gettext";
import { request_editor_modal } from "~js/managers/editor_modal";

customElements.define(
  "emb-post-id-link",
  class extends HTMLDetailsElement {
    connectedCallback() {
      setTimeout(() => {
        const open_editor = () => request_editor_modal(`>>${this.dataset.id}`);

        render(
          this,
          html`
            <summary>>>${this.dataset.id}</summary>
            <div class="content">
              <a
                class="button-link"
                href=${`/post/${this.dataset.id}`}
                target="_blank"
                >${gettext("View post")}</a
              >
              <button class="plain-button" onclick=${open_editor}>
                ${gettext("Quote")}
              </button>
            </div>
          `
        );
      });

      window.addEventListener("click", this.blur_close);
    }

    disconnectedCallback() {
      window.removeEventListener("click", this.blur_close);
    }

    blur_close = (event) => {
      if (!this.contains(event.target)) this.removeAttribute("open");
    };
  },
  { extends: "details" }
);
