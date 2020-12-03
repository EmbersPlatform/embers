// @ts-check

import PubSub from 'pubsub-js';

/** @typedef {import("phoenix").Socket} Socket */
/** @typedef {import("phoenix").Channel} Channel */

const callbacks = {
  /**
   * @param {*} payload
   */
  new_activity(payload) {
    const post = payload.post;
    // post.new = true;
    PubSub.publish("new_activity", post);
  }
}

export default {
  /**
   *
   * @param {Socket} socket
   * @param {string} user_i
   * @returns {Channel}
   */
  init(socket, user_id) {
    const channel = socket.channel(`feed:${user_id}`, {});
    channel.join();

    channel.on("new_activity", callbacks.new_activity);

    return channel;
  }
}
