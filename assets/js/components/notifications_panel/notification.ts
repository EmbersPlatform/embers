import {html} from "heresy";
import { Component } from "../component";

import {dgettext} from "~js/lib/gettext";

interface Notification {
  type?: string,
  from?: string,
  source?: string,
  image?: string
}

export default class ENotification extends Component(HTMLElement) {

  notification: Notification = {};

  onconnected() {
    this.notification.type = this.dataset.type;
    this.notification.from = this.dataset.from;
    this.notification.source = this.dataset.source;
    this.notification.image = this.dataset.image;
  }

  render() {
    this.html`
      <a href=${this.get_link()}>
        <img src=${this.notification.image}>
        ${this.get_type_text()}
      </a>
    `
  }

  get_link() {
    switch(this.notification.type) {
      case "comment": return `/post/${this.notification.source}`;
      case "mention": return `/post/${this.notification.source}`;
    }
  }

  get_type_text() {
    switch(this.notification.type) {
      case "comment": {
        const from = `<strong>${this.notification.from}</strong>`
        const post = `<strong>post</strong>`
        return html`<p>${{html: dgettext("notifications", `${from} replied to your ${post}`)}}</p>`;
      }
      case "mention": {
        const from = `<strong>${this.notification.from}</strong>`
        const post = `<strong>post</strong>`
        return html`<p>${{html: dgettext("notifications", `${from} mentioned you in a ${post}`)}}</p>`;
      }
      default: return `test`
    }
  }
}
