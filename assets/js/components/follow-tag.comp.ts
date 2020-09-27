import { dgettext } from "~js/lib/gettext";
import { Component, reactive } from "./component";
import { html } from "heresy";
import bell_icon from "~static/svg/generic/bell.svg";

export default class FollowTag extends Component(HTMLElement) {
  static component = "FollowTag";

  state = reactive({
    pinned: false,
    following: false
  }, () => this.render())

  pin = () => this.state.pinned = true
  unpin = () => this.state.pinned = false

  follow = () => this.state.following = true
  unfollow = () => this.state.following = false

  render() {
    const pin_btn = html`
      <button class="button primary" onclick=${this.pin}>${dgettext("tags", "Pin")}</button>
    `

    const unpin_btn = html`
      <button class="button" onclick=${this.unpin}>${dgettext("tags", "Unpin")}</button>
    `

    const follow_btn = html`
      <button class="button primary" onclick=${this.follow}>${{html: bell_icon}}</button>
    `;

    const unfollow_btn = html`
      <button class="button" onclick=${this.unfollow}>${{html: bell_icon}}</button>
    `;

    this.html`
      ${this.state.pinned
        ? [
            unpin_btn,
            this.state.following
              ? unfollow_btn
              : follow_btn
          ]
        : pin_btn
      }
    `
  }
}
