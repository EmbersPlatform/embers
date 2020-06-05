import {Component} from "~js/components/component";
import type EmbersSidebar from "~js/components/sidebar";

class EmbersNavigation extends Component(HTMLElement) {
  static tagName = "nav";

  _display_mode
  sidebar_buttons

  oninit() {
    this._display_mode = this.style.display;
    this.sidebar_buttons = this.querySelectorAll(".sidebar-button");
    this.sidebar_buttons.forEach(el => el.addEventListener("click", this.on_click.bind(this)));
  }

  ondisconnect() {
    this.sidebar_buttons.forEach(el => el.removeEventListener("click", this));
  }

  on_click() {
    let sidebar = document.getElementById("sidebar") as EmbersSidebar;
    sidebar.open();
  }

  hide() {
    this.classList.add("input-focus");
  }

  show() {
    this.classList.remove("input-focus");
  }
}

export default EmbersNavigation;
