import {Component} from "~js/components/component";
import type EmbersSidebar from "~js/components/sidebar/sidebar.comp";

export default class EmbersNavigation extends Component(HTMLElement) {
  static component = "EmbersNavigation";
  static tagName = "nav";

  _display_mode
  sidebar_buttons

  oninit() {
    this._display_mode = this.style.display;
    this.sidebar_buttons = this.querySelectorAll(".sidebar-button");
    this.sidebar_buttons.forEach(el => el.addEventListener("click", this.on_click.bind(this)));

    const update_active_links = () => {
      this.querySelectorAll("a").forEach(el => {
        if(window.location.href == el.href) {
          el.classList.add("active")
        } else {
          el.classList.remove("active")
        }
      })
    }

    window.addEventListener("popstate", update_active_links)
    window.addEventListener("pushState", update_active_links)
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
    document.body.classList.add("no-navigation")
  }

  show() {
    this.classList.remove("input-focus");
    document.body.classList.remove("no-navigation")
  }
}
