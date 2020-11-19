import { Component } from "../component";
import { Timer } from "~js/lib/utils/timer";
import anime from "animejs";
import { render, Hole } from "uhtml";

export type ToastContent = string | DocumentFragment | HTMLElement | Hole;

export interface ToastData {
  id?: string;
  content: ToastContent;
  duration?: number;
  classes?: string[];
}

export default class extends Component(HTMLElement) {
  static component = "ToastNotification";

  static mappedAttributes = ["toast"];

  toast: ToastData;
  timer: Timer;

  onconnected() {
    const duration =
      typeof this.toast.duration == "number"
        ? this.toast.duration
        : Math.max(get_read_time(this.toast.content), 5000);

    if (duration > 0) {
      this.timer = new Timer(duration, () => {
        this._expire();
      });
    } else {
      const noop = () => {};
      // @ts-ignore Should probably add a noop timer type instead or handle it
      // differently
      this.timer = {
        pause: noop,
        resume: noop,
      };
    }

    const classes = this.toast.classes;
    if (classes instanceof Array) {
      this.classList.add(...classes);
    }

    this.addEventListener("mouseover", () => this.timer.pause());
    this.addEventListener("mouseleave", () => this.timer.resume());
    this.addEventListener("click", () => {
      this._expire();
    });
  }

  _expire = () => {
    anime({
      targets: this,
      duration: 400,
      easing: "linear",
      keyframes: [{ opacity: 0 }, { height: 0 }],
      complete: () => {
        this.timer.pause();
        this.dispatch("expire", this.toast);
      },
    });
  };

  render() {
    if (this.toast.content instanceof Hole) {
      render(this, this.toast.content);
    } else {
      this.html`
      ${this.toast.content}
    `;
    }
  }
}

const WPM = 200;
const word_size = 5;

const get_read_time = (content: ToastContent): number => {
  let text;

  if (typeof content == "string") {
    text = content;
  } else if (content instanceof Hole) {
    return 5000;
  } else {
    text = content.textContent;
  }

  return text ? (text.length / word_size / WPM) * 60 * 1000 : 5000;
};
