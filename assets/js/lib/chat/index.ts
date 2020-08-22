import { get_user } from "../application";
import * as Channels from "~js/lib/socket/channel";
import s from "flyd";
import { Message } from "./conversation";
import * as Title from "../title";
import * as Fetch from "../utils/fetch";

const current_user = get_user();

/**
 * A stream of messages that arrive via channels
 */
export const messages = s.stream<Message>();

/**
 * A map stream with the count of unread messages per partner id
 */
export const unread_conversations = s.stream<Map<string, number>>(new Map())

/**
 * The unread messages total stream
 */
export const unread_count = unread_conversations.map(conversations => {
  let count = 0;
  for(let unread_count of conversations.values()) {
    count += unread_count;
  }
  return count;
})

// Update the title when the unread messages counter is updated
unread_count.map(count => {
  if(count > 0) {
    Title.flash(`Tienes ${count} mensajes sin leer`);
  } else {
    Title.stop_flash();
  }
})

/**
 * Returns the unread messages map from the page's initial data
 */
const get_unread_messages_from_initial_state = () => {
  const unread = new Map();
  for(let [key, value] of Object.entries(window["embers"]["unseen_messages"])) {
    unread.set(key, value);
  }
  return unread;
}
unread_conversations(get_unread_messages_from_initial_state());


export const list_conversations = async () => {
  const res = await Fetch.get(`/chat/conversations`, {type: "json"});
  switch(res.tag) {
    case "Success": {
      const conversations = await res.value.json();
      return Fetch.FetchResults.Success(conversations);
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
 * Increments the unread messages counter with the given partner id
 * @param partner
 */
export const increment_unread_count = (partner: string) => {
  const conversations = unread_conversations();

  if(!conversations.has(partner)) {
    conversations.set(partner, 1);
  } else {
    conversations.set(partner, conversations.get(partner) + 1);
  }

  unread_conversations(conversations);
}

/**
 * Clears the unread messages counter for the partner
 * @param partner
 */
export const clear_unread_conversation = async (partner: string) => {
  const conversations = unread_conversations();
  conversations.delete(partner);
  unread_conversations(conversations);
}

/**
 * Gets the id of the user the current user was talking to
 * @param message
 */
const get_partner = (message: Message) => {
  return message.sender_id == current_user.id
          ? message.receiver.id
          : message.sender.id
}

/**
 * Refs to the channel subscriptions
 */
let channel_refs: Channels.ChannelRef[] = [];

/**
 * Pushes a channel ref to the channel refs array
 * @param ref
 */
const add_channel_ref = (ref: Channels.ChannelRef) => {
  channel_refs.push(ref);
}

/**
 * Connects to the chat websocket channels
 */
export const connect = () => {
  Channels.subscribe(`user:${current_user.id}`, "new_chat_message", (message: Message) => {
    if(message.sender_id !== current_user.id) {
      increment_unread_count(get_partner(message));
    }

    messages(message)
  })
  .then(add_channel_ref);

  Channels.subscribe(`user:${current_user.id}`, "conversation_read", ({id}) => {
    clear_unread_conversation(id)
  })
  .then(add_channel_ref);
}

/**
 * Disconnects from websocket channels
 */
export const disconnect = () => {
  channel_refs.forEach(Channels.unsubscribe)
}
