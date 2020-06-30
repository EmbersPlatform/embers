import { html } from "heresy";

import { Component } from "../component";
import throttle from "~js/lib/utils/throttle";

import icon_arrow_top from "~static/svg/generic/icons/angle-up.svg";

const scroll_top_threshold = 300;

export default class FabsZone extends Component(HTMLElement) {
  static component = "FabsZone";


  show_scroll_top: boolean;

  onconnected() {
    this.classList.add("soft-kw-hide");
    this._handle_scroll = throttle(this._handle_scroll.bind(this), 500);

    window.addEventListener("scroll", this._handle_scroll);
  }

  ondisconnected() {
    window.removeEventListener("scroll", this._handle_scroll);
  }

  _handle_scroll() {
    const new_val = window.scrollY > scroll_top_threshold;
    if(this.show_scroll_top != new_val) {
      this.show_scroll_top = new_val;
      this.render();
    }
  }

  render() {
    const scroll_top = () => {
      window.scrollTo({top: 0, behavior: 'smooth'})
    }

    this.html`
      ${this.show_scroll_top
        ? html`
          <button onclick=${scroll_top} title="Scroll to top">
            ${{html: icon_arrow_top}}
          </button>
        `
        : ``
      }
    `
  }
}
