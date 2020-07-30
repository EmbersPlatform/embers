import { html } from "heresy";
import { Component } from "../component";
import { gettext } from "~js/lib/gettext";
import * as Settings from "~js/lib/user_settings";

const nsfw_values = [
  {label: gettext("Show NSFW content"), value: "show"},
  {label: gettext("Ask before showing"), value: "ask"},
  {label: gettext("Hide NSFW content"), value: "hide"}
]

export default class extends Component(HTMLElement) {
  static component = "ContentOptions";

  render({useState}: Hooks) {
    const [nsfw, set_nsfw] = useState<string>(this.dataset.settings_nsfw);
    const [updating_nsfw, set_updating_nsfw] = useState(false);
    const [collapse_media, set_collapse_media] =
      useState(this.dataset.settings_collapse_media == "true");

    const update_nsfw = async (event: InputEvent) => {
      if(updating_nsfw) return event.preventDefault();

      const target = event.target as HTMLInputElement;
      const new_value = target.value;
      set_nsfw(new_value);

      set_updating_nsfw(true)
      const result = await Settings.update({content_nsfw: new_value});
      set_updating_nsfw(false)
    }

    const update_collapse_media = async (event) => {
      event.target.disable();
      set_collapse_media(event.detail)
      const result = await Settings.update({content_collapse_media: event.detail});
      event.target.enable();
    }

    this.html`
    <form>
    <fieldset>
      <legend>${gettext("Not Safe For Work content")}</legend>
      ${nsfw_values.map(item => html`
        <label>
          <input
            type="radio"
            id="settings-nsfw-${item.value}"
            value=${item.value}
            .checked=${nsfw == item.value}
            .disabled=${!!updating_nsfw}
            onchange=${update_nsfw}
          >
          ${item.label}
        </label>
      `)}
    </fieldset>
    <fieldset>
      <legend>${gettext("Images")}</legend>
      <switch-input
        onchange=${update_collapse_media}
        .checked=${!!collapse_media}
      >
        ${gettext("Collapse tall images in posts")}
      </switch-input>
    </fieldset>
    </form>
    `
  }
}
