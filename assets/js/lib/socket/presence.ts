// @ts-check

/**
 * This module was ported from old codebase and has not been tested yet
 */

import Socket from './index';
import PubSub from "pubsub-js";
import { Presence } from "phoenix";
import * as Sets from "../utils/sets";

const user_channel = Socket.channels.user;

let presences = new Set();

user_channel.on("presence_state", state => {
  presences = Sets.from(
    Object.keys(
      Presence
      .syncState({}, state)
    )
    .map(key => {
      return state[key].metas[0];
    })
  );
  PubSub.publish("chat.set_online_friends", presences);
});
user_channel.on("presence_diff", diff => {
  presences = Sets.from(
    Object.keys(
      Presence
      .syncDiff(presences, diff)
    )
    .map(key => {
      return diff[key].metas[0];
    })
  );
  PubSub.publish("chat.set_online_friends", presences);
});

// Handle messages that are sent to topics that don't have a client side representation
Socket.socket.onMessage(({
  topic,
  event,
  payload
}) => {
  if (event == "presence_diff" && /^user_presence:\d+$/.test(topic)) {
    // this.presences = Presence.syncDiff(this.presences, payload);

    let joins = Sets.from(
      Presence.list(payload.joins, (_, user) => {
        return user.metas[0];
      })
    );

    let leaves = Sets.from(
      Presence.list(payload.leaves, (_, user) => {
        return user.metas[0];
      })
    );

    if (joins.size > 0) {
      presences = Sets.uniq_by(Sets.union(presences, joins), "username");
    }

    if (leaves.size > 0) {
      presences = Sets.difference_by(presences, leaves, "username");
    }

    PubSub.publish("chat.set_online_friends", presences);
  }
});
