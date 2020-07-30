import { html } from "heresy";
import { Component } from "./component";
import { gettext } from "~js/lib/gettext";
import * as Fetch from "~js/lib/utils/fetch";

export default class extends Component(HTMLElement) {
  static component = "SecurityOptions";

  render({useState}: Hooks) {
    const [status, set_status] = useState("Idle");
    const [sending, set_sending] = useState(false);

    const send = async () => {
      set_sending(true);
      const res = await Fetch.post("/settings/reset_pass");
      switch(res.tag) {
        case "Success": {
          set_status("Success")
          break;
        }
        case "Error": {
          if(res.value.status === 429)
            set_status("RateLimited")
          else
            set_status("Error")
          break;
        }
        case "NetworkError": {
          set_status("Error")
          break;
        }
      }
      set_sending(false);
    }

    this.html`
    ${status == "Success"
    ? html`<div class="alert alert--success">${gettext("A mail was sent with a link to reset your password")}</div>`
    : status == "Error"
    ? html`<div class="alert alert--error">${gettext("An unexpected error ocurred, please try again later")}</div>`
    : status == "RateLimited"
    ? html`<div class="alert alert--error">${gettext("Please wait a few minutes before requesting another password reset")}</div>`
    : ``
    }
    <button
      class="button primary"
      .disabled=${!!sending}
      onclick=${send}
    >${gettext("Reset password")}</button>
    `;
  }
}
