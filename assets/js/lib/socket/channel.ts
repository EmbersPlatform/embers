import Socket from "./index";
const socket = Socket.socket;

import type { Channel, Push } from "phoenix";

type Subscription = {
  refs: Array<number>,
  channel: Channel
}

type MaybePromisifiedSubscription = Subscription | Promise<Subscription>

type callback = (response?: any) => void

let subscriptions: Map<string, MaybePromisifiedSubscription> = new Map();

/**
 * Subscribes to an event on the given topic. Automatically joins the topic
 * if it's not already joined.
 * When resolved returns a ref number used to unsubscribe.
 */
export async function subscribe(topic: string, event: string, callback: callback): Promise<number> {
  if(!subscriptions.has(topic)) {
    await create_channel(topic);
  }

  let sub = subscriptions.get(topic);
  if(sub instanceof Promise) {
    // Wait for subscription to resolve
    sub = await sub;
  }
  const ref = sub.channel.on(event, callback);
  sub.refs.push(ref);

  return ref;
}

/**
 * Unsubscribes the ref from the topic.
 * If there are no refs left, it automatically leaves the channel.
 */
export async function unsubscribe(topic: string, ref: number) {
  if(!subscriptions.has(topic)) return;

  let sub = subscriptions.get(topic);

  if(sub instanceof Promise) {
    // Wait for subscription to resolve
    sub = await sub;
  }
  sub.channel.off(topic, ref);
  sub.refs = sub.refs.filter(r => r !== ref);

  if(sub.refs.length <= 0) {
    // No more refs from this topic, unsubscribe it's channel
    leave_channel(sub.channel);
    subscriptions.delete(topic);
  }
}

/**
 * Adds a promise to the subscriptions map that converts to a Subscription when
 * resolved.
 */
async function create_channel(topic: string): Promise<Subscription> {
  const sub_promise = new Promise((resolve, _reject) => {
    join_channel(topic)
    .then(channel => {
      const sub = {
        channel,
        refs: []
      }
      subscriptions.set(topic, sub)
      return resolve(sub)
    })
  }) as Promise<Subscription>
  subscriptions.set(topic, sub_promise);
  return sub_promise;
}

/**
 * Tries to join a channel for the given topic and returns the channel.
 */
function join_channel(topic: string): Promise<Channel> {
  const channel = socket.channel(topic);
  return new Promise((resolve, reject) => {
    channel.join()
    .receive("ok", _resp => {
      resolve(channel);
    })
    .receive("error", _resp => {
      reject(channel);
    })
  })
}

/**
 *
 * @param {Channel} channel
 * @returns {Push}
 */
function leave_channel(channel: Channel): Push {
  return channel.leave()
}
