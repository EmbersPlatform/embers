import { Component } from "~js/components/component";
import { gettext } from "~js/lib/gettext";
import icon_external from "~static/svg/generic/icons/external-link.svg";

type Avatar = {
  small: string,
  medium: string,
  big: string
}

interface UserData {
  username: string,
  canonical: string,
  email: string,
  bio: string,
  avatar: Avatar,
  cover: string
}

export default class UserSummary extends Component(HTMLElement) {
  static component = "UserSummary";

  user: UserData;

  onconnected() {
    this.user = JSON.parse(this.getAttribute("data"));
  }

  render() {
    this.html`
      <img class="avatar" src=${this.user.avatar.small} />
      <strong>${this.user.username}</strong>
      <e-spacer />
      <a href=${`/@${this.user.canonical}`} target="_blank">${gettext("View profile")} ${{html: icon_external}}</a>
      <button class="button">${gettext("Manage user")}</button>
    `
  }
}
