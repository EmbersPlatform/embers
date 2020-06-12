import { BaseController } from "~js/lib/controller";
import MediaGallery from "~js/components/media_gallery";

export const name = "medias"

export default class extends BaseController {
  static targets = ["gallery"]

  show() {
    if(!this.has_target("gallery")) return;
    this.get_target<MediaGallery>("gallery").show();
  }

  show_at({currentTarget}) {
    if(!this.has_target("gallery")) return;
    this.get_target<MediaGallery>("gallery").show_at(currentTarget.dataset.id)
  }
}
