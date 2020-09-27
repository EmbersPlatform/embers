import ModalDialog from "../dialog/dialog.comp";
import { html } from "heresy";
import { html as uhtml } from "uhtml";
import { dgettext } from "~js/lib/gettext";
import * as Fetch from "~js/lib/utils/fetch";
import status_toasts from "~js/managers/status_toasts";
import { reactive } from "../component";

interface Ban {
  reason: string,
  expires_at: string,
  user: string,
  user_id: string
}

export default class BanDetailsDialog extends ModalDialog {
  static component = "BanDetailsDialog";

  ban: Ban;

  state = reactive({
    sending_unban: false
  }, () => this.render())

  showModal = () => {
    super.showModal();
  }

  close = () => super.close();

  unban = async () => {
    if(this.state.sending_unban) return;
    this.state.sending_unban = true;

    const res = await Fetch.post("/moderation/bans/unban", {user_id: this.ban.user_id}, {type: "json"})
    switch(res.tag) {
      case "Success": {
        status_toasts.add({content: dgettext("moderation", "User unbanned"), classes: ["success"]})
        this.dispatch("unban");
        this.close();
        break;
      }
      default: {
        status_toasts.add({content: dgettext("moderation", "Could not unban user"), classes: ["error"]})
        break;
      }
    }
    this.state.sending_unban = false;
  }

  render() {
    const contents = html`
      <header><p class="dialog-title">${this.ban.user}</p></header>
      <section class="dialog-content">
        <h4>${dgettext("moderation", "Ban reason")}</h4>
        <div>${this.ban.reason}</div>
        <h4>${dgettext("moderation", "Duration")}</h4>
        <div>${duration(this.ban.expires_at)}</div>
      </section>
      <footer>
        <button class="plain-button" onclick=${this.unban} .disabled=${this.state.sending_unban}>${dgettext("moderation", "Unban")}</button>
        <e-spacer></e-spacer>
        <button class="button" onclick=${this.close}>${dgettext("moderation", "Done")}</button>
      </footer>
    `
    this.html`${this.render_dialog(contents)}`
  }

  static style = self => `
    ${self} h4 {
      margin: 0;
      margin-top: 0.5em;
    }

    ${self} .dialog-content div {
      margin: 0;
    }

    ${self} .dialog-content *+*{
      margin-top: 0.5em;
    }

    ${self} footer {
      margin-top: 1em;
    }
  `
}

const duration = (date: string) => {
  return date
    ? date
    : dgettext("moderation", "Permanent")
}
