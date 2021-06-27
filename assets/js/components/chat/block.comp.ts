import { html } from "heresy";
import { Component } from "../component";
import { formatDistance } from "~js/lib/utils/dates";

import { Message } from "~js/lib/chat/conversation";

import { get_user } from "~js/lib/application";
import Conversation from "~js/lib/chat/conversation";

const current_user = get_user();

export default class extends Component(HTMLElement) {
  static component = "MessageBlock";

  static booleanAttributes = ["mine"];
  static mappedAttributes = ["messages", "conversation"];

  messages: Message[] = [];
  user;
  first_message_date: string | number | Date;
  mine: boolean;
  conversation: Conversation;

  oninit() {
    const [first] = this.messages;
    this.user = first.sender;
    this.first_message_date = first.inserted_at;
    this.mine = this.user.id === current_user.id;
  }

  onmessages() {
    this.render();
  }

  render() {
    const formatted_date = formatDistance(
      new Date(this.first_message_date),
      new Date(),
      { addSuffix: true }
    );

    this.html`
    <img class="avatar" src=${this.user.avatar.small} />
    <div class="message-block-messages">
      <span><b>${this.user.username}</b> - <time datetime=${
      this.first_message_date
    } title=${this.first_message_date}>${formatted_date}</time></span>
      ${this.messages.map(
        (message) => html.for(this, message.id || message.nonce)`
        <chat-message .conversation=${this.conversation} .message=${message} />
      `
      )}
    </div>
    `;
  }
}
