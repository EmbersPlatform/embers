import { Component } from "../component";
import * as Notifications from "~js/lib/notifications";

export default class NotificationsBell extends Component(HTMLButtonElement) {
  static component = "NotificationsBell";

  static tagName = "button";

  static mappedAttributes = ["unread_count"];

  unread_count: number;
  counter_element: HTMLElement;

  onconnected() {
    this.counter_element = this.querySelector(".counter");
    this.unread_count = Notifications.unseen_count();

    Notifications.unseen_count.map((count) => {
      this.unread_count = count;
    });
  }

  onunread_count() {
    this.counter_element.textContent = this.unread_count.toString();
    if (this.unread_count < 1) {
      this.counter_element.classList.add("hidden");
    } else {
      this.counter_element.classList.remove("hidden");
    }
  }
}
