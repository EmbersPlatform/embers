import { html, ref } from "heresy";

import { Base } from "#/components/component";

import close_icon from "/static/svg/generic/icons/times.svg";
import arrow_left from "/static/svg/generic/icons/arrow-left.svg";
import arrow_right from "/static/svg/generic/icons/arrow-right.svg";

import Zoomable from "#/components/zoomable";

export default {
  ...Base,
  name: "MediaGallery",
  extends: "element",

  includes: {Zoomable},

  mappedAttributes: ["medias", "open"],

  onconnected() {
    this.dialog = ref();
    this.previous_button = ref();
    this.next_button = ref();

    this.medias =
      Array.from(this.querySelectorAll(":scope > gallery-item"))
      .map(img => ({
        id: img.dataset.id,
        type: img.dataset.type,
        url: img.dataset.src
      }));
  },

  ondisconnected() {
    document.removeEventListener("keydown", this);
  },

  onmedias() {
    this.render();
  },

  onopen() {
    this.render();
  },

  onclose() {
    this.open = false;
  },

  show() {
    this.open = true;
    this.dialog.current.showModal();
  },

  close() {
    this.open = false;
    this.dialog.current.close();
  },

  onkeydown({key}) {
    if(!this.open) return;
    if(key == "ArrowRight") this.next();
    if(key == "ArrowLeft") this.previous();
  },

  render({useState, useEffect}) {
    const [current, setCurrent] = useState(0);

    this.next = () => {
      const next_index = current + 1;
      if(next_index > this.medias.length - 1) return;
      setCurrent(next_index);
      this.next_button.current.focus();
    };

    this.previous = () => {
      const next_index = current - 1;
      if(next_index < 0) return;
      setCurrent(next_index);
      this.previous_button.current.focus();
    };

    this.show_at = id => {
      let index = this.medias.findIndex(m => m.id == id);
      setCurrent(index);
      this.show();
    };

    const handle_click_on_dialog = ({target}) => {
      if(target.localName == "dialog")
        this.close();
    };

    const handle_click_on_media = ({currentTarget, target}) => {
      if(currentTarget === target)
        this.close();
    };

    useEffect(() => {
      document.addEventListener("keydown", this);
    }, []);

    this.html`
      <modal-dialog
        ref=${this.dialog}
        onclick=${handle_click_on_dialog}
        onclose=${this}
        no-background
      >
        <button class="close-button" onclick=${() => this.close()}>
          <i>${{html: close_icon}}</i>
        </button>
        <button
          class="item-control"
          ref=${this.previous_button}
          onclick=${() => this.previous()}
          disabled=${current < 1}
        >
          <i>${{html: arrow_left}}</i>
        </button>
        <div
          class="media-gallery-items"
          data-current=${current}
          style="transform: translateX(${-100 * current}%);"
          >
          ${this.open
          ? this.medias.map((media, i) => html`
            <div class="media-gallery-item" onclick=${handle_click_on_media}>
              ${current == i
                ? html`<Zoomable src=${media.url} />`
                : ``
              }
            </div>
            `)
          : ``}
        </div>
        <button
          class="item-control"
          ref=${this.next_button}
          onclick=${() => this.next()}
          disabled=${current >= this.medias.length - 1}
          >
          <i>${{html: arrow_right}}</i>
        </button>
      </modal-dialog>
    `;
  }
}
