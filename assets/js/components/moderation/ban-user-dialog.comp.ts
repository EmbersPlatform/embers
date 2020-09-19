import { html, ref } from "heresy";
import { gettext } from "~js/lib/gettext";
import ModalDialog from "../dialog/dialog.comp";
import * as Fetch from "~js/lib/utils/fetch";
import status_toasts from "~js/managers/status_toasts";

export default class BanUserDialog extends ModalDialog {
  static component = "BanUserDialog";

  username: string;

  reason_textarea: Ref<HTMLTextAreaElement>;

  permanent: boolean = false;
  duration: number = 7;
  reason: string = "";
  delete_posts: string = "";

  oninit() {
    super.oninit();
    this.reason_textarea = ref();
    this.setAttribute("padded", "");
  }

  // @ts-ignore
  showModal = (username : string) => {
    this.username = username;
    super.showModal();
  }

  close = () => {
    this.username = undefined;
    this.reason_textarea.current.value = "";
    super.close();
  }

  ban_user = async () => {
    const duration = this.permanent ? -1 : this.duration;

    const res = await Fetch.post(`/moderation/ban/user/${this.username}`, {
      reason: this.reason,
      duration: duration,
      delete_posts: this.delete_posts
    }, {type: "json"})

    switch(res.tag) {
      case "Success": {
        status_toasts.add({
          content: gettext("User was banned for %1 days",duration.toString()),
          classes: ["success"]
        });
        this.close();
        break;
      }
      default: {
        status_toasts.add({content: gettext("There was an error"), classes: ["error"]})
        break;
      }
    }
  }

  render() {
    const update_duration = event => {
      this.duration = event.target.value;
      this.render();
    }

    const update_permanent = event => {
      this.permanent = event.target.checked;
      this.render();
    }

    const update_reason = event => {
      this.reason = event.target.value;
    }

    const update_delete_posts = event => {
      this.delete_posts = event.target.value;
    }

    const contents = html`
    <header><p class="dialog-title">${gettext("Ban «@%1»?", this.username)}</p></header>
      <section class="modal-content">
        <div class="form-fields">
          <textarea is="autosize-textarea"
            placeholder=${gettext("Ban reason")}
            ref=${this.reason_textarea}
            oninput=${update_reason}
          ></textarea>
        </div>
        <span class="form-fields-label">${gettext("Duration(days)")}</span>
        <div class="form-fields duration-field">
          <input type="number" value=${this.duration} step="1" min="1" max="365"
            .disabled=${this.permanent}
            onchange=${update_duration}
          >
          <label>
            <input type="checkbox"
              .checked=${this.permanent}
              onchange=${update_permanent}
             >
            ${gettext("Permanent")}
          </label>
        </div>
        <span class="form-fields-label">${gettext("Delete posts?")}</span>
        <div class="form-fields">
          <select onchange=${update_delete_posts}>
            <option value="" selected>${gettext("Don't delete")}</option>
            <option value="1">${gettext("Last 24 hours")}</option>
            <option value="7">${gettext("Last 7 days")}</option>
            <option value="-1">${gettext("Everything")}</option>
          </select>
        </div>
      </section>
      <footer>
        <button class="button" onclick=${this.close}>${gettext("Cancel")}</button>
        <button class="button primary" onclick=${this.ban_user}>${gettext("Ban")}</button>
      </footer>

    `
    this.html`${this.render_dialog(contents)}`
  }

  static style = (self) => `
    ${self} dialog-box {
      width: 400px;
      max-width: 100%;
    }
    ${self} footer {
      margin-top: 0.5em;
    }

    ${self} .duration-field input:disabled {
      opacity: 0.7;
    }

    ${self} .duration-field {
      display: flex;
      flex-direction: row;
    }
  `
}

let registered = false;

export let ban_user_dialog: BanUserDialog;

export const register_modal = () => {
  if(registered) return;
  ban_user_dialog = document.createElement("ban-user-dialog") as BanUserDialog;
  document.body.append(ban_user_dialog);
  registered = true;
}
