import { html, render } from "uhtml";
import * as Fetch from "~js/lib/utils/fetch";
import { dgettext, gettext } from "~js/lib/gettext";
import { reactive } from "./component";

customElements.define(
  "emb-pinned-tags",
  class extends HTMLElement {
    subs = [];

    state = reactive(
      {
        loading: true,
      },
      () => this.update()
    );

    async connectedCallback() {
      this.classList.add("tags-widget");
      const res = await Fetch.get("/tags/pinned", {type: "json"});
      if (res.tag === "Success") {
        const subs = await res.value.json();
        this.subs = subs;
      }
      this.state.loading = false;
    }

    update = () => render(this, () => this.template());

    template = () => html`
      <header>
        <span>${dgettext("pinned-tags", "Pinned tags")}</span>
        <a href="/subs/tags">${dgettext("pinned-tags", "View all")}</a>
      </header>
      ${this.state.loading
        ? html`<p>${gettext("Loading...")}</p>`
        : html`
            <ul>
              ${this.subs.map(
                (sub) => html`
                  <li class="pinned-tag">
                    <a href=${`/tag/${sub.tag.name}`} title=${sub.tag.name}>
                      <p class="tag-name">#${sub.tag.name}</p>
                      ${sub.tag.description
                        ? html`
                            <p class="tag-description tag-misc">
                              ${sub.tag.description}
                            </p>
                          `
                        : ``}
                    </a>
                  </li>
                `
              )}
            </ul>
          `}
    `;
  }
);
