import { html } from "heresy";
import union from "/js/lib/utils/union";

import i18n from "#/lib/gettext";
import { to_base64 } from "#/lib/utils/file";

import { Base } from "#/components/component";

import * as Medias from "#/lib/medias";

import redo_icon from "/static/svg/generic/icons/redo.svg";
import remove_icon from "/static/svg/generic/icons/times.svg";

const MediaItem = {
  ...Base,
  name: "MediaItem",
  extends: "div",

  observedAttributes: ["data-status"],

  onattributechanged({attributeName}) {
    switch (attributeName) {
      case "data-status": {
        this.render();
      }
    }
  },

  oninit() {
    this.dataset.status = "pending";

    this._load_preview()
    this._upload();
  },

  render() {
    const retry = () => this._upload();
    const remove = () => {
      this.dispatch("remove", this.media);
    }

    this.html`
    <div class="media-preview" style="background-image: url(${this.preview});"/>
    ${
      (this.dataset.status === "error")
      ? html`<p class="error">
          <button
            class="plain-button"
            onclick=${retry}
            aria-label=${i18n.dgettext("editor", "Retry")}
            title=${i18n.dgettext("editor", "Retry")}
            tabindex="0"
          >${{ html: redo_icon }}</button>
        </p>`
      : ``
    }
    <button
      class="plain-button"
      onclick=${remove}
      aria-label=${i18n.dgettext("editor", "Remove multimedia")}
      title=${i18n.dgettext("editor", "Remove multimedia")}
      tabindex="0"
    >${{ html: remove_icon }}</button>
    `;
  },

  _load_preview() {
    this.classList.add("media-item-preview")
    to_base64(this.media.data).then(preview => {
      this.preview = preview;
      this.render();
    });
  },

  async _upload() {
    this.dataset.status = "uploading";
    const res = await Medias.upload(this.media.data);
    res.match({
      Success: media => {
        this.dataset.status = "success";
        this.media.data = media;
        this.media.uploaded = true;
        this.dispatch("upload", this.media.data);
      },
      Error: errors => {
        this.dataset.status = "error";
        console.error(errors)
        this.dispatch("error", errors);
      },
      NetworkError: () => {
        this.dataset.status = "error";
        console.error("Network error when uploading media")
        this.dispatch("networkerror");
      }
    });
  }
}

export default MediaItem;
