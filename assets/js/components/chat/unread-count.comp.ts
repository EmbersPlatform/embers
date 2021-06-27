import { Component } from "../component";
import { unread_count } from "~js/lib/chat";

export default class extends Component(HTMLElement) {
  static component = "UnreadChatCounter";

  unread_count$;

  oninit() {
    this.unread_count$ = unread_count.map((count) => {
      count > 0
        ? this.classList.remove("hidden")
        : this.classList.add("hidden");
      this.render();
    })
  }

  ondisconnected() {
    this.unread_count$.end(true);
  }

  render() {
    this.html`${unread_count()}`
  }
}
