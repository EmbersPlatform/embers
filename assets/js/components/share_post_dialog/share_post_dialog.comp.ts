// @ts-check
import {html, ref} from "heresy"
import PubSub from "pubsub-js";

import ModalDialog from "~js/components/dialog/dialog.comp";

import i18n, { gettext } from "~js/lib/gettext";

export default class SharePostDialog extends ModalDialog {
  static component = "SharePostDialog";

  editor
  post
  post_content

  onconnected() {
    this.editor = ref();
  }

  // @ts-ignore
  showModal = (post) => {
    this.post = post;
    this.post_content = this.post
      .querySelector(".post-wrapper")
      .cloneNode(true);
    this.post_content.removeAttribute("embedded");
    this.post_content.removeAttribute("preview");
    this.post_content.querySelector("article.post")?.remove();
    this.post_content.querySelector("post-actions")?.remove();
    super.showModal();
  }

  close = () => {
    this.editor.current.cancel();
    this.post = undefined;
    this.post_content = undefined;
    super.close();
  }

  /**
   * @param {CustomEvent} event
   */
  onpublish(event) {
    this.close();
    PubSub.publish("post.created", event.detail);
    window["status_toasts"].add({content: gettext("The post was shared!"), classes: ["success"]})
  }

  render() {
    if(this._in_preview || !this.post) return;

    const publish = () => this.editor.current.publish();

    this.html`
      ${
        this.render_dialog(
          html`
            <header>
              <p class="dialog-title">${i18n.gettext("Share post")}</p>
            </header>
            <section class="modal-content">
              <post-editor
                ref=${this.editor}
                onpublish=${this}
                data-related_to_id=${this.post.dataset.id}
                noactions notags
              ></post-editor>
            </section>
            <footer>
              <button class="button" onclick=${this.close}>${i18n.dgettext("editor", "Cancel")}</button>
              <button class="button primary" onclick=${publish}>${i18n.dgettext("editor", "Publish")}</button>
            </footer>
            <aside class="modal-content">
              <article class="post" preview>
                ${this.post_content}
              </article>
            </aside>
          `
        )
      }
    `
  }
}
