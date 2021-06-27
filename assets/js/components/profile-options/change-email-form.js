import { define, html, Component, ref, store } from "@dorgandash/untitled";
import { dgettext, gettext } from "~js/lib/gettext";
import * as Fetch from "~js/lib/utils/fetch";

define("emb-change-email-form", class extends Component() {
  connected() {
    /** @type {import("@dorgandash/untitled").Ref<HTMLFormElement>} */
    this.form = ref();

    this.state = this.useStore(
      store({
        errors: {},
        processing: false,
        done: false,
      })
    );
  }

  update_email = async (/** @type {Event} */ event) => {
    event.preventDefault();
    const params = form_to_obj(this.form.current);

    this.state.update({ processing: true });

    const res = await Fetch.put(`/settings/account/update_email`, params, {
      type: "json",
    });

    switch (res.tag) {
      case "Success": {
        this.state.update({ done: true });
        break;
      }
      case "Error": {
        const errors = (await res.value.json()).errors;
        this.state.update((state) => ({ ...state, errors }));
        break;
      }
    }

    this.state.update({ processing: false });
  };

  render() {
    if (!this.state().done) {
      return html`
        <form ref=${this.form} onsubmit=${this.update_email}>
          <h2>${gettext("Change email")}</h2>

          <label class="field field-block">
            <div class="field-title">${gettext("New email")}</div>
            <input type="email" name="email" autocomplete="off" />
            ${this.error_for("email")}
          </label>

          <label class="field field-block">
            <div class="field-title">${gettext("Current password")}</div>
            <emb-password-input>
              <input
                type="password"
                name="current_password"
                autocomplete="current-password"
              />
            </emb-password-input>
            ${this.error_for("current_password")}
          </label>

          <div class="actions">
            <button
              type="button"
              class="button"
              onclick=${() => this.dispatchEvent(new CustomEvent("cancel"))}
            >
              ${gettext("Close")}
            </button>
            <button class="button primary" .disabled=${this.state().processing}>
              ${gettext("Save changes")}
            </button>
          </div>
        </form>
      `;
    } else {
      return html`
        <p>
          ${gettext(
            "A link to confirm your email change has been sent to the new address."
          )}
        </p>
        <div class="actions">
          <button
            type="button"
            class="button"
            onclick=${() => this.dispatchEvent(new CustomEvent("cancel"))}
          >
            ${gettext("Close")}
          </button>
        </div>
      `;
    }
  }

  error_for = (field) => {
    const errors = this.state().errors;
    return errors[field]
      ? errors[field].map(
          (error) => html`<div class="error">${dgettext("errors", error)}</div>`
        )
      : ``;
  };
});

const form_to_obj = (form) => {
  const formdata = new FormData(form);
  let obj = {};
  formdata.forEach((value, key) => {
    obj[key] = value;
  });
  return obj;
};
