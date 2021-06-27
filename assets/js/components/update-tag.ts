import { html, render } from "uhtml";
import { dgettext, gettext } from "~js/lib/gettext";
import { reactive, ref } from "./component"
import { Tag } from "./show-tag-page";
import * as Fetch from "~js/lib/utils/fetch";

customElements.define("emb-update-tag", class extends HTMLElement {

  tag: Tag;

  state = reactive({
    saving: false,
    errored: false
  }, () => this.update())

  connectedCallback() {
    this.update();
  }

  cancel = () => this.dispatchEvent(new CustomEvent("cancel", {bubbles: true}));

  update_tag = async () => {
    this.state.errored = false;
    this.state.saving = true;

    const {name, description} = ref(this);
    const new_tag = {name: name.value, description: description.value};

    const res = await Fetch.put(`/tag/${this.tag.id}`, new_tag, {type: "json"});

    switch(res.tag) {
      case "Success": {
        this.dispatchEvent(new CustomEvent("update", {detail: new_tag, bubbles: true}));
        break;
      }
      default: {
        this.state.errored = true;
        break;
      }
    }

    this.state.saving = false;
  }

  update = () => {
    render(this, html`
      <header>
        <p class="dialog-title">${dgettext("update-tag", "Edit tag «%1»", this.tag.name)}</p>
      </header>
      <section class="tag-details">
        <input ref="name" type="text" value=${this.tag.name} placeholder=${dgettext("update-tag", "Name")} />
        <textarea ref="description" is="autosize-textarea" placeholder=${dgettext("update-tag", "Description")}>${this.tag.description || ""}</textarea>
        ${this.state.errored
          ? html`<p class="text-error">${dgettext("update-tag", "There was an error updating the tag")}</p>`
          : ``
        }
      </section>
      <footer>
        <button .disabled=${this.state.saving} class="button" onclick=${this.cancel}>${gettext("Cancel")}</button>
        <button .disabled=${this.state.saving} class="button primary" onclick=${this.update_tag}>${gettext("Save changes")}</button>
      </footer>
    `)
  }
})
