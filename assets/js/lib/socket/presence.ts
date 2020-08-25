// @ts-check

/**
 * This module was ported from old codebase and has not been tested yet
 */

import * as Channels from './channel';
import Socket from "./index";
import { Presence } from "phoenix";
import * as Sets from "../utils/sets";
import s from "flyd";
import { get_user } from '../application';

console.log(Socket)
const socket = Socket.socket;
const current_user = get_user();
const user_channel = `user:${current_user.id}`;

export const presences = s.stream(new Set());

Channels.subscribe(user_channel, "presence_state", state => {
  const new_presences = Sets.from(
    Object.keys(
      Presence
      .syncState({}, state)
    )
    .map(key => {
      return state[key].metas[0];
    })
  )
  presences(new_presences);
})

Channels.subscribe(user_channel, "presence_diff", diff => {
  const new_presences = Sets.from(
    Object.keys(
      Presence
      .syncDiff(presences, diff)
    )
    .map(key => {
      return diff[key].metas[0];
    })
  )
  presences(new_presences);
})


// Handle messages that are sent to topics that don't have a client side representation
socket.onMessage(({
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
      presences(Sets.uniq_by(Sets.union(presences(), joins), "username"));
    }

    if (leaves.size > 0) {
      presences(Sets.difference_by(presences(), leaves, "username"));
    }
  }
})
