import { html } from "heresy";
import { Base } from "#/components/component";

import MediaItem from "./item";

function build_media(file) {
  return {
    id: `${file.name}_${Date.now()}`,
    data: file,
    uploaded: false
  };
}

const MediaZone = {
  ...Base,
  name: "MediaZone",
  extends: "div",

  includes: {MediaItem},

  mappedAttributes: ["medias"],

  oninit() {
    this.classList.add("media-zone");
    this.medias = this.medias || [];
  },

  reset() {
    this.medias = [];
  },

  add_file(file) {
    if (this.medias.length >= 4) return;
    this.medias.push(build_media(file));
    this.medias = this.medias;
  },

  onmedias() {
    this.render();
  },

  onremove({ detail: media }) {
    this.medias = this.medias.filter(x => x.id !== media.id);
  },

  onupload() {
    this.dispatch("mediachange", this.get_medias())
  },

  get_medias() {
    return this.medias.reduce((acc, media) => {
      if (media.uploaded) return [...acc, media.data];
      return acc;
    }, [])
  },

  render() {
    this.html`
      ${this.medias.map(
        media => html.for(this, media.id)`
          <MediaItem .media=${media} onremove=${this} onupload=${this}/>
        `
      )}
    `;
  }
}

export default MediaZone;
