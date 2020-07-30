import { html } from "heresy";
import { Component } from "./component";
import { gettext } from "~js/lib/gettext";

import * as Settings from "~js/lib/user_settings";

const trust_options = [
  {label: gettext("Everyone"), value: "everyone"},
  {label: gettext("Only those I follow"), value: "followers"}
]

export default class extends Component(HTMLElement) {
  static component = "PrivacyOptions";

  render({useState}: Hooks) {
    const [trust_level, set_trust_level] = useState(this.dataset.trust_level);
    const [show_status, set_show_status] = useState(this.dataset.show_status);
    const [show_reactions, set_show_reactions] = useState(this.dataset.show_reactions);

    const update_trust_level = async (event) => {
      const new_value = event.target.value;
      event.target.disabled = true;
      const result = await Settings.update({privacy_trust_level: new_value});
      if(result.tag === "Success") {
        set_trust_level(new_value);
      }
      event.target.disabled = false;
    }

    const update_show_status = async (event) => {
      const new_value = event.detail;
      event.target.disable();
      console.log({privacy_show_status: new_value})
      const result = await Settings.update({privacy_show_status: new_value});
      if(result.tag === "Success") {
        set_show_status(new_value);
      }
      event.target.enable();
    }

    const update_show_reactions = async (event) => {
      const new_value = event.detail;
      event.target.disable();
      const result = await Settings.update({privacy_show_reactions: new_value});
      if(result.tag === "Success") {
        set_show_reactions(new_value);
      }
      event.target.enable();
    }

    this.html`
    <switch-input
      onchange=${update_show_status}
      .checked=${!!show_status}
    >
      ${gettext("Show my online status")}
    </switch-input>

    <switch-input
      onchange=${update_show_reactions}
      .checked=${!!show_reactions}
    >
      ${gettext("Everyone can see my reactions")}
    </switch-input>

    <section>
      <p><strong>${gettext("Who can comment my posts")}</strong></p>
      <div class="group">
        ${trust_options.map(option => html`
          <label>
          <input
              type="radio"
              id="settings-nsfw-${option.value}"
              value=${option.value}
              .checked=${trust_level == option.value}
              onchange=${update_trust_level}
            >
            <span>${option.label}</span>
          </label>
        `)}
      </div>
    </section>
    `;
  }
}
