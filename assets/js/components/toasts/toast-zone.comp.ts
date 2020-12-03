import { html } from "heresy";
import s from "flyd";
import { Component } from "../component";
import { ToastData } from "./toast-notification.comp";
import random_id from "~js/lib/utils/random_id";

export default class extends Component(HTMLElement) {
  static component = "ToastZone";

  toast_queue: flyd.Stream<ToastData[]>;
  top_toasts: flyd.Stream<ToastData[]>;
  limit: number;

  oninit() {
    this.limit = parseInt(this.dataset.limit) || 5;

    this.toast_queue = s.stream([]);
    this.top_toasts = this.toast_queue.map((toasts) => {
      return toasts.slice(0, this.limit).reverse();
    });

    s.combine(() => this.render(), [this.top_toasts]);
  }

  ondisconnected() {
    this.toast_queue.end(true);
  }

  add = (toast: ToastData) => {
    const id = random_id();
    this.toast_queue([...this.toast_queue(), { ...toast, id }]);
  };

  clear_toast = (toast: ToastData) => {
    const toasts = this.toast_queue().filter((t) => t.id !== toast.id);
    this.toast_queue(toasts);
  };

  clear = () => this.toast_queue([]);

  render() {
    this.html`
      ${this.top_toasts().map(
        (toast) => html.for(this, toast.id)`
        <toast-notification .toast=${toast} onexpire=${(e) =>
          this.clear_toast(e.detail)}/>
      `
      )}
    `;
  }
}
