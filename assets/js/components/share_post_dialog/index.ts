// @ts-check
import {html, ref} from "heresy"
import PubSub from "pubsub-js";

import ModalDialog from "~js/components/dialog";

import i18n from "~js/lib/gettext";

export default class SharePostDialog extends ModalDialog {

  editor
  post
  post_content

  oninit() {
    super.oninit();
    this.editor = ref();
    this.post = this.closest("article.post");
    this.post_content = this.post
      .querySelector(".post-wrapper")
      .cloneNode(true);
    this.post_content.removeAttribute("embedded");
    this.post_content.removeAttribute("preview");

    let embedded_post = this.post_content.querySelector("article.post")
    if(embedded_post) {
      embedded_post.remove();
    }
  }

  open() {
    this.showModal();
  }

  /**
   * @param {CustomEvent} event
   */
  onpublish(event) {
    this.close();
    PubSub.publish("post.created", event.detail);
  }

  render() {
    const cancel = () => {
      this.editor.current.cancel();
      this.close();
    }

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
              <button class="button" onclick=${cancel}>${i18n.dgettext("editor", "Cancel")}</button>
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
