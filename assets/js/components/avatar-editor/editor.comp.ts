import { Component } from "../component";

import { html, ref } from "heresy";
import { to_base64 } from "~js/lib/utils/file";
import { dgettext, gettext } from "~js/lib/gettext";

import * as Profile from "~js/lib/profile";

export default class extends Component(HTMLElement) {
  static component = "AvatarEditor";

  static mappedAttributes = ["status"];

  avatar: string;
  status: "Idle" | "Uploading" = "Idle";
  cropper;
  file_input;
  dialog;

  constructor() {
    super();
    this.cropper = ref();
    this.file_input = ref();
    this.dialog = ref();
  }

  onconnected() {
    super.initialize();
    if (this._in_preview) return;
    this.avatar = this.dataset.src;
  }

  onstatus() {
    this.render();
  }

  render() {
    if (this._in_preview) return;

    const cancel = () => {
      this.dialog.current.close();
      this.cropper.current.refresh();
      this.status = "Idle";
    };

    const confirm = async () => {
      this.status = "Uploading";
      const avatar = (await this.cropper.current.result({
        type: "blob",
      })) as Blob;
      const res = await Profile.update_avatar(avatar);
      this.dialog.current.close();
      if (res.tag !== "Success") {
        this.status = "Idle";
        return console.error(avatar);
      }
      this.avatar = res.value.medium;
      this.cropper.current.refresh();
      this.status = "Idle";
    };

    const pick_avatar = () => {
      this.file_input.current.click();
    };

    const select_avatar = async (event: Event) => {
      this.dialog.current.showModal();
      this.cropper.current._resize_cropper();
      const target = event.target as HTMLInputElement;
      const file = Array.from(target.files)[0];
      const base64 = await to_base64(file);
      this.cropper.current.set_image(base64);
    };

    this.html`
      <img src=${this.avatar}>
      <button class="button primary" onclick=${pick_avatar}>${dgettext(
      "profile-options",
      "Change avatar"
    )}</button>
      <input
        ref=${this.file_input}
        type="file"
        style="display: none;"
        onchange=${select_avatar}
        accept=".jpg,.jpeg,.png"
      >
      <modal-dialog padded ref=${this.dialog}>
        <div>
          <croppable-image
          ref=${this.cropper}
          data-size_w="256"
          data-size_h="256"
          />
        </div>
        <footer>
          ${
            this.status == "Uploading"
              ? html` <span>${gettext("Saving changes...")}</span> `
              : html`
                  <button class="button" onclick=${cancel}>
                    ${gettext("Cancel")}
                  </button>
                  <button class="button primary" onclick=${confirm}>
                    ${gettext("Save changes")}
                  </button>
                `
          }

        </footer>
      </modal-dialog>
    `;
  }
}
