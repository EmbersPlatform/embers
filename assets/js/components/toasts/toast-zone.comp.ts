import { html } from "heresy";
import s from "flyd";
import { Component } from "../component";
import { Toast } from "./toast-notification.comp";
import random_id from "~js/lib/utils/random_id";

export interface ToastOptions {
  content: Toast["content"],
  duration?: number
}

export default class extends Component(HTMLElement) {
  static component = "ToastZone";

  toast_queue: flyd.Stream<Toast[]>;
  top_toasts: flyd.Stream<Toast[]>;
  limit: number;

  oninit() {
    this.limit = parseInt(this.dataset.limit) || 5;

    this.toast_queue = s.stream([]);
    this.top_toasts = this.toast_queue.map(toasts => {
      return toasts.slice(0, this.limit).reverse();
    })

    s.combine(() => this.render(), [this.top_toasts])
  }

  ondisconnected() {
    this.toast_queue.end(true);
  }

  add = (toast: ToastOptions) => {
    const id = random_id();
    this.toast_queue([...this.toast_queue(), {...toast, id}]);
  }

  clear_toast = (toast: Toast) => {
    const toasts = this.toast_queue().filter(t => t.id !== toast.id);
    this.toast_queue(toasts);
  }

  clear = () => this.toast_queue([])

  render() {
    this.html`
      ${this.top_toasts().map(toast => html.for(this, toast.id)`
        <toast-notification .toast=${toast} onexpire=${e => this.clear_toast(e.detail)}/>
      `)}
    `
  }

  static style = (self) => `
    ${self} {
      position: fixed;
      top: 0;
      left: 0;
      z-index: 10;
      display: flex;
      flex-direction: column;
      align-items: center;
    }

    ${self}[bottom-left] {
      top: auto;
      bottom: 1em;
      left: calc(var(--navigation-width) + 0.5em);
      width: calc(var(--sidebar-width) - 1em);
    }

    ${self}[top-center] {
      top: 0.5em;
      left: 50%;
      transform: translateX(-50%);
      width: calc(var(--sidebar-width) - 1em);
    }
  `
}
