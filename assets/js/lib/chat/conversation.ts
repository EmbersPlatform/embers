import * as Fetch from "~js/lib/utils/fetch";
import * as Chat from "./index";
import { stream, combine } from "flyd";

import { UserData, get_user } from "../application";

const current_user = get_user();

export interface Message {
  id?: string,
  nonce?: string,
  inserted_at?: string | Date | number,
  read_at?: string | Date | number,
  receiver?: UserData,
  receiver_id?: string,
  sender?: UserData,
  sender_id?: string,
  text: string,
  unsent?: boolean
}

interface GetMessagesOptions {
  before?: string
}

type ConversationStatus = "Idle" | "Loading" | "Error";
export default class Conversation {

  user_id: string;
  messages = stream<Message[]>()
  status = stream<ConversationStatus>("Idle")
  last_page = stream(false)
  next = stream<string>()

  unread_count: flyd.Stream<number>;
  new_messages: flyd.Stream<any>;

  pending_read_conversation = false;

  constructor(user_id: string) {
    this.user_id = user_id;
    this.unread_count = combine((unred_convos, prev) => {
      const new_unread = unred_convos().get(this.user_id) || 0;

      if(new_unread !== prev()) {
        return new_unread;
      }
    }, [Chat.unread_conversations])
  }

  async init() {
    this.status("Loading");
    const response = await this.get_messages();
    switch(response.tag) {
      case "Success": {
        this.status("Idle");
        this.messages(response.value.body.reverse());
        this.last_page(response.value.last_page);
        this.next(response.value.next);
        break
      }
      case "Error":
      case "NetworkError": {
        this.status("Error");
        break;
      }
    }

    this.new_messages = Chat.messages.map((message) => {
      const nonce = message.nonce;
      if(
        // Current user is the sender and has a matching receiver
            (message.receiver.id == this.user_id
          && message.sender.id == current_user.id)
        // Current user is the receiver and has a matching sender
        ||  (message.sender.id == this.user_id
          && message.receiver.id == current_user.id)
        // Current user is the same as the receiver(messages to self)
        ||  (message.sender.id == current_user.id
          && message.receiver.id == current_user.id)
      ) {
        const already_there = nonce && !!this.messages().find(m => m.nonce == nonce)
        if(already_there) return;
        this.append_messages([message])
      }
    })
  }

  cleanup = () => {
    this.status.end();
    this.messages.end();
    this.last_page.end();
    this.next.end();
    this.new_messages.end();
  }

  /**
   * Loads more messages and prepends it to the `messages` stream
   */
  load_more = async (): Promise<Fetch.NetResult<Message[], Object>> => {
    if(this.last_page()) return;
    if(this.status() == "Loading") return;

    this.status("Loading");
    const response = await this.get_messages({before: this.next()})
    switch(response.tag) {
      case "Success": {
        const messages = response.value.body.reverse();
        this.status("Idle");
        this.last_page(response.value.last_page);
        this.next(response.value.next);
        this.messages([...messages, ...this.messages()]);
        return Fetch.FetchResults.Success(response.value.body)
      }
      case "Error":
        this.status("Error");
        return Fetch.FetchResults.Error(response.value)
      case "NetworkError": {
        this.status("Error");
        return Fetch.FetchResults.NetworkError()
      }
    }
  }

  /**
   * Loads messages from the server
   * @param options
   */
  get_messages = async (options: GetMessagesOptions = {}): Promise<Fetch.NetResult<Fetch.PaginationPage<Message[]>, Object>> => {
    const params = {before: options.before, entries: true}
    const res = await Fetch.get(`/chat/${this.user_id}/messages`, {params})
    switch(res.tag) {
      case "Success": {
        const page = await res.value.json();
        return Fetch.FetchResults.Success(page);
      }
      case "Error": {
        const errors = await res.value.json();
        return Fetch.FetchResults.Error(errors);
      }
      case "NetworkError": {
        return Fetch.FetchResults.NetworkError()
      }
    }
  }

  /**
   * Sends a message
   * @param message
   */
  send_message = async (message: Message)  => {
    const res = await Fetch.post(`/chat`, message, {type: "json"})
    switch(res.tag) {
      case "Success": {
        const message = await res.value.json();
        this.messages(
          this.messages().map(m => {
            if(m.nonce === message.nonce) {
              return message;
            }
            return m;
          })
        )
        return Fetch.FetchResults.Success(message);
      }
      case "Error": {
        const errors = await res.value.json();
        return Fetch.FetchResults.Error(errors);
      }
      case "NetworkError": {
        return Fetch.FetchResults.NetworkError()
      }
    }
  }

  /**
   * Notifies the server that the conversation has been read
   */
  read = async () => {
    if(this.pending_read_conversation) return;
    if(this.unread_count() <= 0) return;

    this.pending_read_conversation = true;
    await Fetch.put(`/chat/${this.user_id}`);
    this.pending_read_conversation = false;
  }

  /**
   * Appends messages to the messages stream
   * @param messages
   */
  append_messages = (messages: Message[]) => {
    this.messages([...this.messages(), ...messages]);
  }
  /**
   * prepends messages to the messages stream
   * @param messages
   */
  prepend_messages = (messages: Message[]) => {
    this.messages([...messages, ...this.messages()]);
  }
}
