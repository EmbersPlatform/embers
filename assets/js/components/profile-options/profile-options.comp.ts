import { Component } from "../component";
import { gettext } from "~js/lib/gettext";

import * as Profile from "~js/lib/profile";
import { show_dialog } from "~js/managers/dialog";
import { html } from "uhtml";

import "./change-email-form";

export default class extends Component(HTMLElement) {
  static component = "ProfileOptions";

  render({ useState }: Hooks) {
    const [status, setStatus] = useState<"Idle" | "Updating">("Idle")
    const [bio, setBio] = useState(this.dataset.bio);

    const update = async () => {
      if (status === "Updating") return;
      setStatus("Updating");
      const result = await Profile.update_profile({ bio });
      setStatus("Idle");
    }

    const prompt_update_email = () => {
      show_dialog((_dialog, close) =>
        html`
          <emb-change-email-form oncancel=${close} />
        `
      )
    }

    this.html`
    <div class="field">
      <div class="field-row">
        <div class="field-title"><strong>${gettext("Username")}</strong></div>
        <span>${this.dataset.username}</span>
      </div>
    </div>
    <div class="field">
      <div class="field-row">
        <div class="field-title"><strong>${gettext("Email")}</strong></div>
        <span>${this.dataset.email}</span>
      </div>
      <button class="button" onclick=${prompt_update_email}>${gettext("Update")}</button>
    </div>
    <label class="field">
      <div class="field-row">
        <strong class="field-title">${gettext("Bio")}</strong>
        <textarea is="autosize-textarea" onchange=${e => setBio(e.target.value)}
                                          placeholder=${gettext("A short description about yourself")}
                                          >${bio}</textarea>
      </div>
    </label>
    <button class="button primary" onclick=${update} .disabled=${status === "Updating"}>${status === "Updating"
      ? gettext("Saving changes...")
      : gettext("Save changes")
    }</button>
    `
  }
}
