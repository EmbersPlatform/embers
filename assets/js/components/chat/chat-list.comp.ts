import { html } from "heresy";
import { Component } from "../component";
import * as Chat from "~js/lib/chat";

export default class extends Component(HTMLElement) {
  static component = "ChatList";

  conversations = [];

  streams = [];

  async oninit() {
    const res = await Chat.list_conversations();
    switch(res.tag) {
      case "Success": {
        this.conversations = res.value;
        this.render();
        break;
      }
    }

    this.streams.push(
      Chat.unread_conversations.map(() => this.render())
    );
  }

  cleanup = () => {
    this.streams.forEach(s => s.end(true));
  }

  render() {
    this.html`
      ${this.conversations.map(chat_list_item)}
    `
  }
}

const chat_list_item = (user) => {
  const unread_count = Chat.unread_conversations().get(user.id);

  return html`
    <a class="conversation-user" href=${`/chat/@${user.canonical}`}>
      ${!!unread_count
        ? html`<span class="conversation-unread-count">${unread_count}</span>`
        : ``
      }
      <figure class="avatar" size="medium">
        <img src=${user.avatar.small}>
      </figure>
      <span class="username">${user.canonical}</span>
    </a>
  `
}
