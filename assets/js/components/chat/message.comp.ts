import { html } from "heresy";
import { Component } from "../component";
import Conversation, { Message } from "~js/lib/chat/conversation";
import { gettext, dgettext } from "~js/lib/gettext";

type MessageStatus = "Idle" | "Sending" | "Error";

export default class extends Component(HTMLElement) {
  static component = "ChatMessage";

  static mappedAttributes = ["message", "conversation", "status"];

  message: Message;
  conversation: Conversation;

  status: MessageStatus = "Idle";

  onconnected() {
    if(this.message.unsent) {
      this.send();
    }
  }

  async send() {
    if(this.status === "Sending" || !this.message.unsent) return;

    this.status = "Sending";

    const res = await this.conversation.send_message(this.message);
    switch(res.tag) {
      case "Success": {
        this.dispatch("publish", {nonce: this.message.nonce, ...res.value}, {bubbles: true});
        break;
      }
      case "NetworkError":
      case "Error": {
        this.status = "Error";
        break;
      }
    }
  }

  retry() {
    if(this.status !== "Error") return;
    this.send();
  }

  onmessage() {
    this.render();
  }

  onstatus() {
    this.render();
  }

  render() {
    if(this.status == "Error")
      this.classList.add("error")
    else
      this.classList.remove("error");

    if(this.status == "Sending")
      this.classList.add("sending")
    else
      this.classList.remove("sending");

    this.html`
    <leg-markdown>${this.message.text}</leg-markdown>
    ${this.status == "Error"
      ? html`
        <div class="error-message">
          <span>${dgettext("chat", "The message could not be sent")} -</span>
          <button class="plain-button" onclick=${() => this.retry()}>${gettext("Retry")}</button>
        </div>
        `
      : ``
    }
    `
  }
}
