import { html } from "heresy";
import { Component } from "../component";

import * as Notifications from "~js/lib/notifications";

import { dgettext } from "~js/lib/gettext";

interface Notification {
  type?: string;
  from?: string;
  source?: string;
  image?: string;
}

export default class ENotification extends Component(HTMLElement) {
  static component = "ENotification";

  notification: Notification = {};

  onconnected() {
    this.notification.type = this.dataset.type;
    this.notification.from = this.dataset.from;
    this.notification.source = this.dataset.source;
    this.notification.image = this.dataset.image;

    this.read = this.read.bind(this);

    this.addEventListener("click", this.read);
  }

  ondisconnected() {
    this.removeEventListener("click", this.read);
  }

  async read() {
    if (this.dataset.status === "read") return;
    await Notifications.read(this.dataset.id);
  }

  render() {
    this.html`
      <a href=${this.get_link()}>
        <img src=${this.notification.image}>
        <p>${{ html: Notifications.render_text(this.notification) }}</p>
      </a>
    `;
  }

  get_link() {
    switch (this.notification.type) {
      case "comment":
        return `/post/${this.notification.source}`;
      case "mention":
        return `/post/${this.notification.source}`;
    }
  }
}
