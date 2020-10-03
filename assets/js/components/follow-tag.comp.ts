import { dgettext } from "~js/lib/gettext";
import { Component, reactive } from "./component";
import { html } from "heresy";
import bell_icon from "~static/svg/generic/bell.svg";
import { set_subscription_level, unsubscribe } from "~js/lib/tags";

/**
 * 0 - pinned
 * 1 - subscribed
 */

export default class FollowTag extends Component(HTMLElement) {
  static component = "FollowTag";

  state = reactive({
    pinned: false,
    following: false,
    loading: false
  }, () => this.render());

  onconnected() {
    const level = parseInt(this.dataset.level);

    switch(level) {
      case 0: {
        this.state.pinned = true;
        break;
      }
      case 1: {
        this.state.pinned = true;
        this.state.following = true;
        break;
      }
    }
  }

  pin = () => this.do_unless_loading(async () => {
    if(await this.update_level(0))
      this.state.pinned = true;
  })

  unpin = () => this.do_unless_loading(async () => {
    if(await unsubscribe(this.dataset.tagId)) {
      this.state.following = false;
      this.state.pinned = false;
    }
  })

  follow = () => this.do_unless_loading(async () => {
    if(await this.update_level(1))
      this.state.following = true;
  })

  unfollow = () => this.do_unless_loading(async () => {
    if(await this.update_level(0))
      this.state.following = false;
  })

  update_level = async (level: number) => {
    return await set_subscription_level(this.dataset.tagId, level);
  }

  do_unless_loading = fn => {
    if(this.state.loading) return;
    this.state.loading = true;
    fn();
    this.state.loading = false;
  }

  render() {
    const pin_btn = html`
      <button class="button primary" onclick=${this.pin} .disabled=${this.state.loading}>${dgettext("tags", "Pin")}</button>
    `;

    const unpin_btn = html`
      <button class="button" onclick=${this.unpin} .disabled=${this.state.loading}>${dgettext("tags", "Unpin")}</button>
    `;

    const follow_btn = html`
      <button class="button primary" onclick=${this.follow} .disabled=${this.state.loading}>${{html: bell_icon}}</button>
    `;

    const unfollow_btn = html`
      <button class="button" onclick=${this.unfollow} .disabled=${this.state.loading}>${{html: bell_icon}}</button>
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
    `;
  }

  static style = (self) => `
    ${self} {
      display: inline-flex;
    }

    ${self} > * + * {
      margin-left: 0.2em;
    }
  `
}
