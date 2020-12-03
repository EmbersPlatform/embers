import { html, ref } from "heresy";
import { gettext } from "~js/lib/gettext";
import status_toasts from "~js/managers/status_toasts";
import ModalDialog from "./dialog/dialog.comp";
import PostEditor from "./editor/editor.comp";
import back_icon from "/static/svg/generic/icons/angle-left.svg";

export default class PostEditorModal extends ModalDialog {
  static component = "PostEditorModal";

  editor: Ref<PostEditor>;

  default_content = "";

  oninit() {
    super.oninit();
    this.editor = ref();
    this.setAttribute("padded", "");
  }

  close = () => {
    this.editor.current.cancel();
    this.default_content = "";
    super.close();
  };

  handle_publish = () => {
    status_toasts.add({
      content: html`${gettext("Post published!")} <a href="">View post</a>`,
    });
    this.close();
  };

  showModal(default_content = "") {
    this.default_content = default_content;
    super.showModal();
    this.editor.current.cancel();
    this.editor.current.focus();
  }

  render() {
    const content = html`
      <header>
        <button class="plain-button" onclick=${close}>
          ${{ html: back_icon }}
        </button>
        <span>${gettext("Create post")}</span>
      </header>
      <post-editor
        ref=${this.editor}
        onpublish=${this.handle_publish}
        data-default-content=${this.default_content}
      ></post-editor>
    `;

    this.html`${this.render_dialog(content)}`;
  }
}
