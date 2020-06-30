import { html } from "heresy";
import { Component } from "~js/components/component";

import MediaItem from "./item";
import { Media } from "~js/lib/medias";

export type FileToUpload = {tag: "File", id: string, value: File}
export type UploadedMedia = {tag: "Media", id: string, value: Media}
export type FileOrMedia = FileToUpload | UploadedMedia;

function build_file(file: File): FileOrMedia {
  return {
    tag: "File",
    id: `${file.name}_${Date.now()}`,
    value: file
  };
}

class MediaZone extends Component(HTMLDivElement) {
  static tagName = "div";

  static includes = {MediaItem};

  static mappedAttributes = ["medias"];

  medias: FileOrMedia[]

  oninit() {
    this.classList.add("media-zone");
    this.medias = this.medias || [];
  }

  reset() {
    this.medias = [];
  }

  add_file(file: File) {
    if (this.medias.length >= 4) return;
    this.medias.push(build_file(file));
    this.medias = this.medias;
  }

  onmedias() {
    this.render();
  }

  onremove({ detail: media }) {
    this.medias = this.medias.filter(x => x.id !== media.id);
  }

  onupload(event: CustomEvent) {
    const media = event.detail as FileOrMedia;
    const index = this.medias.findIndex(m => m.id === media.id);
    this.medias[index] = event.detail;
    this.dispatch("mediachange", this.get_medias());
  }

  get_medias() {
    return this.medias.reduce<FileOrMedia[]>((acc, media) => {
      if (media.tag === "Media") return [...acc, media];
      return acc;
    }, [])
  }

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
