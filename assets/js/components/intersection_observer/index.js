import { Base } from "../component";

export default {
  ...Base,
  name: "IntersectionObserver",
  extends: "element",

  oninit() {
    this.height = this.offsetHeight + "px" || "20px";

    this.style.height = this.height;

    this.observer = new IntersectionObserver(([entry]) => {
      if (entry.intersectionRatio > 0) {
        this.dispatch("intersect");
      }
    });
    this.observer.observe(this);
  },

  ondisconnect() {
    if (this.observer) this.observer.disconnect();
  }
}
