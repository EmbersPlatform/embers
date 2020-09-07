import { Component } from "../component";
import { Timer } from "~js/lib/utils/timer";
import anime from "animejs";

export interface Toast {
  id: string,
  content: string | DocumentFragment | HTMLElement,
  duration?: number,
  classes?: string[]
}

export default class extends Component(HTMLElement) {
  static component = "ToastNotification";

  static mappedAttributes = ["toast"];

  toast: Toast;
  timer: Timer;

  onconnected() {
    const duration = (typeof this.toast.duration == "number")
      ? this.toast.duration : Math.max(get_read_time(this.toast.content), 5000);

      if(duration > 0) {
        this.timer = new Timer(duration, () => {
          this._expire();
        })
      } else {
        const noop = () => {};
        // @ts-ignore Should probably add a noop timer type instead or handle it
        // differently
        this.timer = {
          pause: noop, resume: noop
        }
      }

    const classes = this.toast.classes;
    if(classes instanceof Array) {
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
      keyframes: [
        {opacity: 0},
        {height: 0}
      ],
      complete: () => {
        this.timer.pause();
        this.dispatch("expire", this.toast);
      }
    })
  }

  render() {
    this.html`
      ${this.toast.content}
    `
  }

  static style = (self) => `
    ${self} {
      display: block;
      width: 100%;
      background: var(--toast-background, var(--primary));
      color: var(--toast-foreground, var(--color));
      padding: 0.5em;
      box-shadow: var(--box-shadow);
      border: var(--border);
      border-radius: var(--border-radius);
    }

    ${self} + ${self} {
      margin-top: 0.5em;
    }

    ${self}.success {
      border-left: 0.3em solid var(--success);
    }

    ${self}.danger {
      border-left: 0.3em solid var(--danger);
    }

    ${self}.warning {
      border-left: 0.3em solid var(--warning);
    }
  `
}

const WPM = 200
const word_size = 5;

const get_read_time = (content: string | HTMLElement | DocumentFragment): number => {
  let text;

  if(typeof content == "string") {
    text = content;
  } else {
    text = content.textContent;
  }

  return text.length/word_size/WPM * 60 * 1000
}
