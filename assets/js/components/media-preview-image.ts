import { define } from "wicked-elements";

define("[media-preview-image]", {
  connected() {
    const image = this.element.querySelector("img");
    const height = image.height;

    if (height > 600) {
      this.element.classList.add("tall-image");
    }

    console.debug(image, height);
  },
});
