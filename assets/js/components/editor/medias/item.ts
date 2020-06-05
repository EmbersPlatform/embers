import { html } from "heresy";

import i18n from "~js/lib/gettext";
import { to_base64 } from "~js/lib/utils/file";

import { Component } from "~js/components/component";

import * as Medias from "~js/lib/medias";
import type {FileOrMedia, UploadedMedia} from "./zone";

import redo_icon from "/static/svg/generic/icons/redo.svg";
import remove_icon from "/static/svg/generic/icons/times.svg";

class MediaItem extends Component(HTMLDivElement) {
  static tagName = "div";

  static observedAttributes = ["data-status"];

  media: FileOrMedia;
  preview: string;

  onattributechanged({attributeName}) {
    switch (attributeName) {
      case "data-status": {
        this.render();
      }
    }
  }

  oninit() {
    this.dataset.status = "pending";

    this._load_preview()
    this._upload();
  }

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
  }

  _load_preview() {
    if(this.media.tag !== "File") return;

    this.classList.add("media-item-preview")
    to_base64(this.media.value).then(preview => {
      this.preview = preview;
      this.render();
    });
  }

  async _upload() {
    if(this.media.tag !== "File") return;

    this.dataset.status = "uploading";
    const res = await Medias.upload(this.media.value);
    switch(res.tag) {
      case "Success": {
        const media = res.value;
        this.dataset.status = "success";
        this.media = {tag: "Media", id: this.media.id, value: media}
        this.dispatch("upload", this.media);
        break;
      }
      case "Error": {
        const errors = res.value;
        this.dataset.status = "error";
        console.error(errors)
        this.dispatch("error", errors);
        break;
      }
      case "NetworkError": {
        this.dataset.status = "error";
        console.error("Network error when uploading media")
        this.dispatch("networkerror");
        break;
      }
    }
  }
}

export default MediaItem;
