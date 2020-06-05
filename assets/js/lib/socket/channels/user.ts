// @ts-check

import PubSub from 'pubsub-js';

/** @typedef {import("phoenix").Socket} Socket */
/** @typedef {import("phoenix").Channel} Channel */

const callbacks = {
  notification(payload) {
    PubSub.publish("new_notification", payload);
  },
  new_chat_message(payload) {
    PubSub.publish("new_chat_message", payload);
  },
  conversation_read(payload) {
    PubSub.publish("conversation_read", payload);
  },
  chat_typing(payload) {
    PubSub.publish("chat_typing", payload);
  }
}

export default {
  /**
   *
   * @param {Socket} socket
   * @param {string} user_id
   * @returns {Channel}
   */
  init(socket, user_id) {
    const channel = socket.channel(`user:${user_id}`, {});
    channel.join();

    channel.on("notification", callbacks.notification);

    channel.on("new_chat_message", callbacks.new_chat_message);

    channel.on("conversation_read", callbacks.conversation_read);

    channel.on("chat_typing", callbacks.chat_typing);

    return channel;
  }
}
