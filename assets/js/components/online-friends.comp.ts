import { html } from "heresy";
import { Component } from "./component";
import { presences } from "~js/lib/socket/presence";
import { gettext } from "~js/lib/gettext";

import send_icon from "~static/svg/generic/inbox.svg";

export default class extends Component(HTMLElement) {
  static component = "OnlineFriends";

  presences_mapper;

  onconnected() {
    this.presences_mapper = presences.map(() => {
      this.render()
    });
  }

  ondisconnected() {
    this.presences_mapper.end(true);
  }

  render() {
    const online_friends = Array.from(presences());
    this.html`
      ${online_friends.length > 0
        ? render_presences(online_friends)
        : gettext("There are no online friends")
      }
    `
  }
}

const render_presences = presences =>
  presences.map(render_presence)

const render_presence = presence =>
  html`
  <div class="presence">
    <a
      href=${`/@${presence.username}`}
      class="row-user"
    >
      <figure class="avatar">
        <img src=${presence.avatar.small} />
      </figure>
      <span class="username">${presence.username}</span>
    </a>
    <a
      href=${`/chat/@${presence.username}`}
      class="button-link"
    >${{html: send_icon}}</a>
  </div>
  `
