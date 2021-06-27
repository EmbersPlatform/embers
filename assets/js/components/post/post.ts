import { define } from "wicked-elements";
import { share_post } from "~js/managers/post";

define("article[post]", {
  // @ts-ignore
  onClick(event: MouseEvent) {
    if((<HTMLElement>event.target).matches("[share-trigger]")) {
      event.stopPropagation();
      share_post(this.element);
    }
  }
})
