import { html, ref } from "heresy";
import differenceInMinutes from "date-fns/differenceInMinutes";

import { Component } from "../component";

import back_icon from "/static/svg/generic/icons/angle-left.svg";
import publish_icon from "~static/svg/generic/inbox.svg";
import EmbersNavigation from "../navigation/navigation.comp";

import * as Chat from "~js/lib/chat";
import Conversation, { Message } from "~js/lib/chat/conversation";
import { get_user } from "~js/lib/application";
import random_id from "~js/lib/utils/random_id";
import { dgettext } from "~js/lib/gettext";

const current_user = get_user();

const navigation = document.getElementById("navigation") as EmbersNavigation;

export default class extends Component(HTMLElement) {
  static component = "ChatConversation";

  messages_blocks;
  message_textarea;

  conversation: Conversation;

  streams: flyd.Stream<any>[] = [];

  async oninit() {
    this.messages_blocks = ref();
    this.message_textarea = ref();

    this.conversation = new Conversation(this.dataset.userId);

    this.streams.push(
      this.conversation.messages.map(() => {
        const messages_block = this.messages_blocks.current as HTMLElement;
        const old_height = messages_block.scrollHeight;
        const old_scroll = messages_block.scrollTop;

        const scroll_bottom = get_scroll_bottom(this.messages_blocks.current);

        this.render()

        if(scroll_bottom <= 20) {
          // If near the bottom of the list, scroll to the bottom of it
          this.scroll_to_bottom();
          this.conversation.read();
        } else {
          // If not, then restore previous scroll position
          const height_diff = messages_block.scrollHeight - old_height;
          this.messages_blocks.current.scrollTop = old_scroll + height_diff - 20;
        }
      })
    )

    this.streams.push(
      this.conversation.unread_count.map(() => this.render())
    )

    requestAnimationFrame(() => navigation.hide());

    await this.conversation.init();
    this.scroll_to_bottom();
  }

  ondisconnected() {
    navigation.show();
    this.streams.forEach(s => s.end(true));
    this.conversation.cleanup();
  }

  scroll_to_bottom = () => {
    let nodes = this.messages_blocks.current.querySelectorAll("chat-message");
    let last = nodes[nodes.length - 1];
    if(last) {
      last.scrollIntoView();
    } else {
      this.messages_blocks.current.scrollTop = this.messages_blocks.current.scrollHeight;
    }
    this.conversation.read();
  }

  load_more = async () => {;
    await this.conversation.load_more();
  }

  private send_message = () => {
    const text = this.message_textarea.current.value;
    this.message_textarea.current.value = "";

    const new_message = {
      nonce: random_id(),
      unsent: true,
      sender: current_user,
      receiver_id: this.dataset.userId,
      inserted_at: new Date(),
      text
    };
    this.conversation.append_messages([new_message]);
    this.scroll_to_bottom();
  }

  private maybe_send = (event: KeyboardEvent) => {
    if(event.key !== "Enter" || event.shiftKey) return;

    const target = event.target as HTMLTextAreaElement;

    if(target.value.length <= 0) return;

    event.preventDefault();

    this.send_message();
  }

  private go_back = () => history.back();

  render() {
    const grouped_messages = group_messages(this.conversation.messages());
    const unread_count = Chat.unread_conversations().get(this.dataset.userId) || 0;

    const handle_send_button = event => {
      // event.preventDefault();
      this.message_textarea.current.focus();
      this.send_message();
    }

    this.html`
    <header>
      <button class="plain-button" onclick=${this.go_back}>${{html: back_icon}}</button>
      <img class="avatar" src=${this.dataset.avatar}/><span>${this.dataset.username}</span>
    </header>
    <section class="message-blocks" ref=${this.messages_blocks}>
      ${this.conversation.last_page()
        ? `Inicio de la conversación con ${this.dataset.username}`
        : ``
      }
      <intersect-observer onintersect=${this.conversation.load_more}/>
      ${grouped_messages.map(messages => html.for(this, messages[0].id)`
        <message-block .conversation=${this.conversation} .messages=${messages} />
      `)}
      <intersect-observer onintersect=${this.conversation.read}/>

        ${unread_count
          ? html`
            <button class="unread-messages-notice" onclick=${this.scroll_to_bottom}>
              Hay mensajes sin leer
            </button>
          `
          : ``
        }
    </section>
    <footer class="chat-editor">
      <textarea
        is="autosize-textarea"
        ref=${this.message_textarea}
        onkeydown=${this.maybe_send}
        placeholder=${dgettext("chat", `Send message to @%1`, this.dataset.username)}
      ></textarea>
      <button class="plain-button chat-send-button" onfocus=${handle_send_button}>${{html: publish_icon}}</button>
    </footer>
    `
  }
}

function group_messages(messages: Message[]) {
  if(!messages) return [];
  const acc = messages.reduce(
    (acc, m, i, arr) => {
      if (i == 0) {
        acc.blocks[acc.index] = [m];
        return acc;
      } else {
        const previous = arr[i - 1]
        const prev_date = new Date(previous.inserted_at);
        const current_date = new Date(m.inserted_at);
        const dates_diff = differenceInMinutes(current_date, prev_date);

        const too_new = Math.abs(dates_diff) > 5;
        if (too_new || previous.sender.id != m.sender.id) {
          acc.index++;
          acc.blocks[acc.index] = [m]
          return acc;
        } else {
          acc.blocks[acc.index].push(m);
          return acc;
        }
      }
    },
    { index: 0, blocks: [] }
  );
  return acc.blocks;

}

function get_scroll_bottom(element) {
  return element.scrollHeight - (element.scrollTop + element.offsetHeight);
}
