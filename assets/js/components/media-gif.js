import { html } from "uhtml";
import { reactive } from "./component"

customElements.define("emb-media-gif", class extends HTMLDivElement {
  /**
   * @type {HTMLImageElement}
   */

  img;
  /**
   * @type {string}
   */
  thumbnail_url;

  /**
   * @type {string}
   */
  original_url;

  state = reactive({
    playing: false
  }, () => this.update())

  connectedCallback() {
    setTimeout(() => {
      this.img = this.querySelector("img");
      this.thumbnail_url = this.dataset.thumbUrl;
      this.original_url = this.dataset.originalUrl;

      const img_rect = this.img.getBoundingClientRect()
      if(img_rect.width > 40 && img_rect.height > 30) {
        this.prepend(html.node`<span class="gif-label">GIF</span>`)
        this.addEventListener("mouseover", () => this.state.playing = true);
        this.addEventListener("mouseleave", () => this.state.playing = false)
      } else {
        this.img.src = this.original_url;
      }
    })
  }

  update = () => {
    if(this.state.playing) {
      this.img.src = this.original_url
      this.setAttribute("playing", "");
    } else {
      this.img.src = this.thumbnail_url
      this.removeAttribute("playing")
    }
  }
}, {extends: "div"})
