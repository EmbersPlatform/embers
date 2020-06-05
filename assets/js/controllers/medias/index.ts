import { Controller } from "stimulus"

export const name = "medias"

export default class extends Controller {
  static targets = ["gallery"]

  show() {
    if(!this.hasGalleryTarget) return;
    this.galleryTarget.show();
  }

  show_at({currentTarget}) {
    if(!this.hasGalleryTarget) return;
    this.galleryTarget.show_at(currentTarget.dataset.id)
  }
}
