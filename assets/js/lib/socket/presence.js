import socket from "@/lib/socket";
import store from "@/store";
import { Presence } from "phoenix";
import _ from "lodash";

let user_id = window.appData.user.id;
let user_channel = socket.channel(`user:${user_id}`, {});
user_channel.join();

let presences = [];

user_channel.on("presence_state", state => {
  presences = Object.keys(Presence.syncState({}, state)).map(key => {
    return state[key].metas[0];
  });
  store.dispatch("chat/set_online_friends", presences);
});
user_channel.on("presence_diff", diff => {
  presences = Object.keys(Presence.syncDiff(presences, diff)).map(key => {
    return state[key].metas[0];
  });
  store.dispatch("chat/set_online_friends", presences);
});

// Handle messages that are sent to topics that don't have a client side representation
socket.onMessage(({ topic, event, payload }) => {
  if (event == "presence_diff" && /^user_presence:\d+$/.test(topic)) {
    // this.presences = Presence.syncDiff(this.presences, payload);

    let joins = Presence.list(payload.joins, (_, user) => {
      return user.metas[0];
    });
    let leaves = Presence.list(payload.leaves, (_, user) => {
      return user.metas[0];
    });

    if (joins.length > 0) {
      presences = _.uniqBy(_.union(presences, joins), "username");
    }
    if (leaves.length > 0) {
      presences = _.differenceBy(presences, leaves, "username");
    }

    store.dispatch("chat/set_online_friends", presences);
  }
});
