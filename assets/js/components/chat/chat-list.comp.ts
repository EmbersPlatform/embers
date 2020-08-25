import { html, ref } from "heresy";
import { Component } from "../component";
import * as Chat from "~js/lib/chat";
import { dgettext } from "~js/lib/gettext";
import plus_icon from "~static/svg/generic/plus.svg";

export default class extends Component(HTMLElement) {
  static component = "ChatList";

  conversations = [];

  streams = [];

  new_message_modal;

  oninit() {
    this.new_message_modal = ref();

    Chat.list_conversations().then(res => {
      switch(res.tag) {
        case "Success": {
          this.conversations = res.value;
          this.render();
          break;
        }
      }
    });

    this.streams.push(
      Chat.unread_conversations.map(() => this.render())
    );
  }

  cleanup = () => {
    this.streams.forEach(s => s.end(true));
  }

  render() {
    this.html`
      <button class="new-message-button" onclick=${() => this.new_message_modal.current.showModal()}>
        ${{html: plus_icon}}
        <span>${dgettext("chat", "New message")}</span>
      </button>
      <!--👻 Should conversations be wrapped in another element? -->
      ${this.conversations.map(render_list_item)}
      <new-message-modal ref=${this.new_message_modal} />
    `
  }
}

const render_list_item = (user) => {
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
