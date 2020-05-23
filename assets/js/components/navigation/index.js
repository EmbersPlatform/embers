const EmbersNavigation = {
  name: "EmbersNavigation",
  extends: "nav",

  oninit() {
    this._display_mode = this.style.display;
    this.sidebar_buttons = this.querySelectorAll(".sidebar-button");
    this.sidebar_buttons.forEach(el => el.addEventListener("click", this));
  },

  ondisconnect() {
    this.sidebar_buttons.forEach(el => el.removeEventListener("click", this));
  },

  onclick() {
    let sidebar = document.getElementById("sidebar");
    sidebar.open();
  },

  hide() {
    this.classList.add("input-focus");
  },

  show() {
    this.classList.remove("input-focus");
  }
}

export default EmbersNavigation;
