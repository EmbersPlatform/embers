import { html } from "heresy";
import { Component } from "../component";

import * as Settings from "~js/lib/user_settings";
import { gettext, dgettext } from "~js/lib/gettext";

const themes = [
  {label: gettext("Dark"), value: "dark"},
  {label: gettext("Light"), value: "light"},
]

export default class extends Component(HTMLElement) {
  static component = "DesignOptions";

  render({useState}: Hooks) {
    const [theme, set_theme] = useState(this.dataset.theme);
    const [updating_theme, set_updating_theme] = useState(false);

    const update_theme = async (event) => {
      set_updating_theme(true);
      const new_theme = event.target.value;
      const result = await Settings.update({style_theme: new_theme});
      if(result.tag === "Success") {
        set_theme(new_theme);
        document.body.setAttribute("theme", new_theme);
      }
      set_updating_theme(false);
    }

    // @ts-ignore
    const user = window.embers.user;

    this.html`
      <div class="group">
        ${themes.map(theme_ => html`
          <label>
            <div theme=${theme_.value}>
              <article class="post">
                <section class="post-wrapper">
                  <header>
                    <figure class="avatar" size="medium">
                      <img src="${user.avatar.small}">
                    </figure>
                    <div class="post-details">
                      <div class="details-top">
                        <a class="username">${ user.username}</a>
                      </div>
                      <div class="details-bottom">
                        <a>
                          <time>${ dgettext("design-options", "5 minutes ago") }</time>
                        </a>
                      </div>
                  </div>
                  </header>
                  <section class="post-content">
                    <section class="post-body">
                      ${ dgettext("design-options", "Hello world!") }
                    </section>
                  </section>
                  <footer></footer>
                </section>
              </article>
            </div>
            <input
              type="radio"
              id="settings-nsfw-${theme_.value}"
              value=${theme_.value}
              .checked=${theme == theme_.value}
              .disabled=${!!updating_theme}
              onchange=${update_theme}
            >
            <span>${theme_.label}</span>
          </label>
        `)}
    </div>
    `;
  }
}
