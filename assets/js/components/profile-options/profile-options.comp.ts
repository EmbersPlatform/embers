import { Component } from "../component";
import { gettext } from "~js/lib/gettext";

import * as Profile from "~js/lib/profile";

export default class extends Component(HTMLElement) {
  static component = "ProfileOptions";

  render({useState}: Hooks) {
    const [status, setStatus] = useState<"Idle" | "Updating">("Idle")
    const [bio, setBio] = useState(this.dataset.bio);

    const update = async () => {
      if(status === "Updating") return;
      setStatus("Updating");
      const result = await Profile.update_profile({bio});
      setStatus("Idle");
    }

    this.html`
    <label>
      <strong>${gettext("Username")}</strong>
      <input type="text" disabled value=${this.dataset.username}>
    </label>
    <label>
      <strong>${gettext("Email")}</strong>
      <input type="text" disabled value=${this.dataset.email}>
    </label>
    <label>
      <strong>Bio</strong>
      <textarea
        is="autosize-textarea"
        onchange=${e => setBio(e.target.value)}
        placeholder=${gettext("A short description about yourself")}
      >${bio}</textarea>
    </label>
    <button
      class="button primary"
      onclick=${update}
      .disabled=${status === "Updating"}
    >${
      status === "Updating"
      ? gettext("Saving changes...")
      : gettext("Save changes")
    }</button>
    `
  }
}
