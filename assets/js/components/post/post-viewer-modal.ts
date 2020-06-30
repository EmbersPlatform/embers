import { html } from "heresy";
import ModalDialog from "../dialog";
import Turbolinks from "turbolinks";

import back_icon from "/static/svg/generic/icons/angle-left.svg";
import { dgettext } from "~js/lib/gettext";
import random_id from "~js/lib/utils/random_id";

export default class extends ModalDialog {
  static component = "PostViewerModal";

  load: (post_id: string) => void;

  restoration_uuid: string;

  onconnected() {
    super.initialize();
    if(this._in_preview) return;
    this.cleanup = this.cleanup.bind(this);
    window.addEventListener("popstate", this.cleanup);
  }

  cleanup() {
    super.close();
    window.removeEventListener("popstate", this.cleanup);
  }

  close() {
    history.back();
    // this.cleanup();
  }

  // @ts-ignore
  render({useState} : Hooks) {
    if(this._in_preview) return;

    const [contents, setContents] = useState(null);

    this.load = async post_id => {
      this.restoration_uuid = random_id();
      // Turbolinks.controller.pushHistoryWithLocationAndRestorationIdentifier(post_id, this.restoration_uuid)
      window.history.pushState({custom: false}, null, post_id)


      this.showModal();
      setContents(html`
      <p>${dgettext("post-viewer-modal", "Loading post...")}</p>
      `);

      const content_res = await fetch(post_id);
      const content_str = await content_res.text();
      const content_html = document.createRange().createContextualFragment(content_str);
      const main_content = content_html.querySelector(".main-content");


      setContents(html`
        <div view="post">
          <main>
            ${main_content}
          </main>
        </div>
      `);
    }

    const close = () => this.close();

    const template = html`
      <header>
        <button class="plain-button" onclick=${close}>${{html: back_icon}}</button>
        <span>${dgettext("post-viewer-modal", "Post details")}</span>
      </header>
      ${contents}
    `

    this.html`${this.render_dialog(template)}`
  }
}
