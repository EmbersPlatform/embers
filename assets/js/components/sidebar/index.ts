import Hammer from "hammerjs";

import {Component} from "~js/components/component";
// Should this be extracted into it's own dragger component?

export default class EmbersSidebar extends Component(HTMLElement) {
  static component = "EmbersSidebar";
  static tagName = "nav";

  static mappedAttributes = ["sidebar_x"];

  sidebar_x: number
  panning_sidebar: boolean
  overlay: HTMLElement
  gestures: HammerManager

  oninit() {
    this.panning_sidebar = false;
    this.sidebar_x = 0;

    this.overlay = this._get_or_create_overlay();
    this.overlay.addEventListener("click", this.on_click.bind(this));

    this._create_gesture_manager();
  }

  ondisconnected() {
    if (this.gestures) this.gestures.destroy();
    this.overlay.removeEventListener("click", this.on_click.bind(this));
    this.overlay.remove();
  }

  is_open() {
    return this.sidebar_x == this.offsetWidth;
  }

  open() {
    if (this.is_open()) return;
    this.sidebar_x = this.offsetWidth;
  }

  close() {
    this.sidebar_x = 0;
  }

  on_click(event) {
    this.close();
  }

  onpanstart(event) {
    if (Math.abs(event.deltaY) > Math.abs(event.deltaX)) return;
    if (event.target.nodeName.toLowerCase() == "input") return;
    if (event.target.closest(".custom-dialog")) return;
    if (
      !this.panning_sidebar &&
      this.sidebar_x < this.offsetWidth &&
      event.center.x > window.innerWidth / 2
    )
      return;
    this.panning_sidebar = true;
  }

  onpanleft(event) {
    if (!this.panning_sidebar || this.sidebar_x == 0) return;
    this._set_sidebar_x(event);
  }

  onpanright(event) {
    if (!this.panning_sidebar || this.sidebar_x == this.offsetWidth) return;
    this._set_sidebar_x(event);
  }

  onpanend(event) {
    if (!this.panning_sidebar) return;
    if (this.sidebar_x < 140) this.close();
    if (this.sidebar_x >= 140) this.open();
    this.panning_sidebar = false;
  }

  onsidebar_x({detail}) {
    this.style.transform = `translateX(${detail}px)`;

    if (this.overlay) {
      let overlay_opacity = (this.sidebar_x / this.offsetWidth) * 100;

      if (overlay_opacity == 0) this.overlay.style.display = "none";
      else this.overlay.style.display = "block";

      this.overlay.style.opacity = `${overlay_opacity}%`;
    }
  }

  _create_gesture_manager() {
    // Don't create gesture detector if touchevents aren't available
    // NOTE: Requires `Modernizr`
    if (!window["Modernizr"].touchevents) return;

    this.gestures = new Hammer.Manager(document.getElementById("embers"));
    this.gestures.add(
      new Hammer.Pan({ direction: Hammer.DIRECTION_HORIZONTAL})
    );

    // Attaching events like this feels wrong, Hammer.js expects a function as
    // a handler, so the eventHandler standard pattern doesn't work
    // Is the bind even necessary?
    this.gestures.on("panstart", e => this.onpanstart(e));
    this.gestures.on("panleft", e => this.onpanleft(e));
    this.gestures.on("panright", e => this.onpanright(e));
    this.gestures.on("panend", e => this.onpanend(e));
  }

  _set_sidebar_x(event) {
    let { deltaX } = event;
    if (deltaX < 0) {
      deltaX = Math.max(deltaX, -this.offsetWidth);
      this.sidebar_x = this.offsetWidth + deltaX;
    } else {
      deltaX = Math.min(deltaX, this.offsetWidth);
      this.sidebar_x = deltaX;
    }
  }

  _get_or_create_overlay(): HTMLElement {
    let existing_overlay = this.parentNode.querySelector(".sidebar-overlay") as HTMLElement;
    if (existing_overlay) return existing_overlay;

    let new_overlay = document.createElement("div");
    new_overlay.classList.add("sidebar-overlay");
    new_overlay.style.opacity = "0";
    new_overlay.style.display = "none";
    this.parentNode.append(new_overlay);
    return new_overlay;
  }
}
