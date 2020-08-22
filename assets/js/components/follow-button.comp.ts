import { Component } from "./component";

import * as Users from "~js/lib/users";

import icon_follow from "/static/svg/generic/icons/user-plus.svg";
import icon_unfollow from "/static/svg/generic/icons/user-minus.svg";

export default class extends Component(HTMLButtonElement) {
  static component = "FollowButton";
  static tagName = "button";

  static booleanAttributes = ["following", "textless"];

  following: boolean;
  textless: boolean;

  oninit() {
    this.on_click = this.on_click.bind(this);
    this.addEventListener("click", this.on_click);
  }

  async on_click() {
    if(this.disabled) return;

    this.disabled = true;
    let ok;

    ok = this.following
      ? await Users.unfollow(this.dataset.id, {type: "json"})
      : await Users.follow(this.dataset.id, {type: "json"})

    this.disabled = false;

    if(ok) {
      this.following = !this.following;
      this.render();
    }
  }

  render() {
    const text = this.following
      ? `Dejar de seguir`
      : `Seguir`

    const icon = this.following
      ? {html: icon_unfollow}
      : {html: icon_follow}

    this.title = text;

    const button_text = this.textless ? `` : text;

    this.html`${icon}${button_text}`;
  }
}
