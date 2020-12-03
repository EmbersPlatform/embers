import { Component } from "../component";

export default class IntersectObserver extends Component(HTMLElement) {
  static component = "IntersectObserver";

  observer: IntersectionObserver;

  oninit() {
    this.style.height = this.offsetHeight > 0
      ? this.offsetHeight + "px"
      : "1px";

    this.observer = new IntersectionObserver(([entry]) => {
      if (entry.intersectionRatio > 0) {
        this.dispatch("intersect");
      }
    });
    this.observer.observe(this);
  }

  ondisconnect() {
    if (this.observer) this.observer.disconnect();
  }
}
