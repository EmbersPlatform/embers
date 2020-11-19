import * as Channel from "~js/lib/socket/channel";
import TimelineController from ".";
import { get_settings } from "~js/lib/application";

import * as PostsDOM from "~js/components/post/dom";

export default class ActivitiesCache {
  activities: HTMLElement[] = [];
  channel_refs: Map<string, Channel.ChannelRef> = new Map();

  timeline: TimelineController;

  constructor(timeline: TimelineController) {
    this.timeline = timeline;
  }

  add(post_html: string) {
    let post = PostsDOM.parse(post_html.trim());
    console.log(post_html, post);

    // Ignore the post if it's nsfw and the user doesn't want to see nsfw
    if (get_settings().content_nsfw === "hide" && PostsDOM.is_nsfw(post))
      return;

    post = PostsDOM.format_content_warning(post);

    this.activities.push(post);

    const post_id = post.dataset.id;

    (async () => {
      Channel.subscribe(`post:${post_id}`, "deleted", () => {
        this.remove_by_id(post_id);
      }).then((ref) => this.channel_refs.set(post_id, ref));

      Channel.subscribe(`post:${post_id}`, "tags_updated", ({ new_tags }) => {
        this.update_post(post_id, (post) =>
          PostsDOM.update_tags(post, new_tags)
        );
      }).then((ref) => this.channel_refs.set(post_id, ref));
    })();

    this.timeline._update_alert();
  }

  update_post(post_id, fn: (el: HTMLElement) => HTMLElement) {
    this.activities = this.activities.map((post) => {
      if (post.dataset.id !== post_id) return post;
      return fn(post);
    });
  }

  remove_by_id(post_id) {
    this.activities = this.activities.filter((p) => p.dataset.id != post_id);
    this.timeline._update_alert();
  }

  flush() {
    const activities = this.activities;
    this.activities = [];
    this.channel_refs.forEach((ref) => Channel.unsubscribe(ref));
    this.timeline._update_alert();
    return activities;
  }

  get length() {
    return this.activities.length;
  }

  get entries() {
    return this.activities;
  }
}
