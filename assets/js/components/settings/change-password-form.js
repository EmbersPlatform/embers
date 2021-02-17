import { define, Component, html, ref, store } from "@dorgandash/untitled";
import { dgettext, gettext } from "~js/lib/gettext";
import * as Fetch from "~js/lib/utils/fetch";

/**
 * @template T
 * @typedef {import("@dorgandash/untitled").Ref<T>} Ref
 */

define("emb-change-password-form", class extends Component() {
  connected() {
    this.state = this.useStore(
      store({
        errors: {},
        processing: false,
        done: false,
      })
    );

    /** @type {Ref<HTMLFormElement>} */
    this.form = ref();

    /** @type {Ref<HTMLInputElement>} */
    this.input_new_password_ref = ref();
    /** @type {Ref<HTMLInputElement>} */
    this.input_new_password_confirm_ref = ref();
  }

  check_confirmation = () => {
    const pwd = this.input_new_password_ref.current;
    const confirm = this.input_new_password_confirm_ref.current;
    const form = this.form.current;

    form.classList.remove("password-matches");
    form.classList.remove("password-mismatch");

    if (!pwd.value || !confirm.value) return;

    if (pwd.value !== confirm.value) {
      confirm.setCustomValidity(dgettext("errors", "Passwords must match"));
      form.classList.add("password-mismatch");
      form.classList.remove("password-matches");
    } else {
      confirm.setCustomValidity("");
      form.classList.add("password-matches");
      form.classList.remove("password-mismatch");
    }
  };

  update_password = async (event) => {
    event.preventDefault();
    const params = form_to_obj(this.form.current);

    this.state.update({ processing: true });

    const res = await Fetch.put(`/settings/account/update_password`, params, {
      type: "json",
    });

    switch (res.tag) {
      case "Success": {
        this.state.update({ done: true });
        setTimeout(() => location.reload(), 5000);
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
        <form ref=${this.form} onsubmit=${this.update_password}>
          <h2>${gettext("Change password")}</h2>
          <div class="g-small-text g-text-warning g-margin-bottom">
            ${gettext(
              "Note: all your other active sessions will be logged out."
            )}
          </div>
          <label class="field">
            <div class="field-title">${gettext("New password")}</div>
            <div class="field-description">
              ${gettext(
                "At least %1 characters. It can be a phrase with spaces too.",
                "12"
              )}
            </div>
            <emb-password-input>
              <input
                type="password"
                name="password"
                autocomplete="new-password"
                required
                minlength="12"
                onkeyup=${this.check_confirmation}
                ref=${this.input_new_password_ref}
              />
            </emb-password-input>
            ${this.error_for("password")}
          </label>
          <label class="field">
            <div class="field-title">${gettext("Confirm new password")}</div>
            <emb-password-input>
              <input
                type="password"
                name="password_confirmation"
                autocomplete="new-password"
                required
                minlength="12"
                onkeyup=${this.check_confirmation}
                ref=${this.input_new_password_confirm_ref}
              />
            </emb-password-input>
            ${this.error_for("password_confirmation")}
          </label>
          <label class="field">
            <div class="field-title">${gettext("Current password")}</div>
            <emb-password-input>
              <input
                type="password"
                name="current_password"
                required
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
        <div class="success-message">
          ${gettext(
            "Your password has been updated. This page will reload shortly " +
              "to apply changes."
          )}
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
