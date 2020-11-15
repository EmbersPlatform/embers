import { html } from "uhtml";
import { reactive } from "./component";

customElements.define("emb-media-gif", class extends HTMLDivElement {

  connectedCallback() {
    setTimeout(() => {
      const thumbnail_url = this.dataset.thumbUrl;
      const original_url = this.dataset.originalUrl;

      const state = reactive(
        {
          playing: false,
        },
        () => update()
      );

      const img = this.querySelector("img");

      const img_poll = setInterval(() => {
        if(img.naturalWidth) {
          clearInterval(img_poll);

          const img_rect = img.getBoundingClientRect();

          if (img_rect.width > 40 && img_rect.height > 30) {
            this.prepend(html.node`<span class="gif-label">GIF</span>`);
            this.addEventListener("mouseover", () => (state.playing = true));
            this.addEventListener("mouseleave", () => (state.playing = false));
          } else {
            img.src = original_url;
          }
        }
      }, 10)

      const update = () => {
        if (state.playing) {
          img.src = original_url;
          this.setAttribute("playing", "");
        } else {
          img.src = thumbnail_url;
          this.removeAttribute("playing");
        }
      }
    })
  }
}, {extends: "div"});
