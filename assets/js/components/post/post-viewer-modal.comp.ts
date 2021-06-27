import { html } from "heresy";
import ModalDialog from "../dialog/dialog.comp";

import back_icon from "/static/svg/generic/icons/angle-left.svg";
import { dgettext } from "~js/lib/gettext";
import Pjax from "pjax-api";

export default class PostViewerModal extends ModalDialog {
  static component = "PostViewerModal";

  load: (post_id: string) => void;

  restoration_uuid: string;

  onconnected() {
    super.initialize();
    if(this._in_preview) return;
    this.popclose = this.popclose.bind(this)
    this.clickclose = this.clickclose.bind(this)
    this.close = this.close.bind(this)
    this.cleanup = this.cleanup.bind(this);
  }

  cleanup() {
    window.removeEventListener("popstate", this.popclose);
    window.removeEventListener("pjax:unload", this.clickclose);
  }

  popclose() {
    Pjax.sync();
    super.close();
    this.cleanup()
  }

  clickclose() {
    super.close();
    this.cleanup()
  }

  close() {
    history.back();
    Pjax.sync()
    super.close()
    this.cleanup();
  }

  // @ts-ignore
  render({useState} : Hooks) {
    if(this._in_preview) return;

    const [contents, setContents] = useState(null);
    const [username, setUsername] = useState(null);

    this.load = async post_id => {
      this.showModal();
      document.body.classList.remove("loading-page");

      setContents(html`
      <p>${dgettext("post-viewer-modal", "Loading post...")}</p>
      `);

      window.addEventListener("popstate", this.popclose);
      window.addEventListener("pjax:fetch", this.clickclose);

      const url = `/post/${post_id}`;

      window.history.pushState(null, null, url)
      Pjax.sync()

      const content_res = await fetch(url);
      const content_str = await content_res.text();
      const content_html = document.createRange().createContextualFragment(content_str);
      const main_content = content_html.querySelector(".main-content");
      setUsername(main_content.querySelector(".username").textContent);

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
        <span>
          ${ username
            ? dgettext("post-viewer-modal", `@%1's post`, username)
            : dgettext("post-viewer-modal", `Post details`)
          }</span>
      </header>
      ${contents}
    `

    this.html`${this.render_dialog(template)}`
  }
}

document.addEventListener("click", async (event) => {
  const target = event.target as HTMLElement;
  const anchor = target.closest("a[data-post-id]") as HTMLAnchorElement;
  if(!anchor || anchor.closest("dialog, [view=post]")) return;
  event.preventDefault()
  event.stopPropagation()

  const dialog = document.getElementById("post-viewer-modal") as PostViewerModal;
  dialog.load(anchor.dataset.postId)
})
