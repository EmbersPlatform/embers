import { Component } from "../component";

export default class PopUp extends Component(HTMLElement) {
  static component = "PopUp";


  trigger: HTMLElement;

  onconnected() {
    this.addEventListener("click", this.on_click.bind(this));
    document.addEventListener("click", this.on_click_outside.bind(this));
  }

  ondisconnected() {
    this.removeEventListener("click", this.on_click.bind(this));
    document.removeEventListener("click", this.on_click_outside.bind(this));
  }

  open() {
    this.setAttribute("open", "true");
    if(this.trigger) {
      this.trigger.classList.add("pop-up-active");
    }
  }

  close() {
    this.removeAttribute("open");
    if(this.trigger) {
      this.trigger.classList.remove("pop-up-active");
      this.trigger = null;
    }
  }

  on_click(event: MouseEvent) {
    const target = event.target as HTMLElement;
    const trigger = target.closest("[pop-up-trigger]") as HTMLElement;
    if(trigger && this.contains(trigger)) {
      this.trigger = trigger;
      this.open();
    }
  }

  on_click_outside(event: MouseEvent) {
    if (!this.contains(event.target as Node)) {
      this.close();
    }
  }
}
