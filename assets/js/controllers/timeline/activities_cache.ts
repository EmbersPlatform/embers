import * as Channel from "~js/lib/socket/channel";

export default class ActivitiesCache {

  activities: HTMLElement[] = [];
  channel_refs: Map<string, number> = new Map();

  timeline;

  constructor(timeline) {
    this.timeline = timeline;
  }

  add(post_html) {
    const post = document
      .createRange()
      .createContextualFragment(post_html)
      .firstChild as HTMLElement;

    const post_id = post.dataset.id;
    this.activities.push(post);

    Channel.subscribe(`post:${post_id}`, "deleted", () => {
      this.remove_by_id(post_id);
    })
    .then(ref => this.channel_refs.set(post_id, ref))

    this.timeline._update_alert();
  }

  remove_by_id(post_id) {
    this.activities = this.activities.filter(p => p.dataset.id != post_id);
    this.timeline._update_alert();
  }

  flush() {
    const activities = this.activities;
    this.activities = [];
    this.channel_refs.forEach(
      (ref, post_id) => Channel.unsubscribe(`post:${post_id}`, ref)
    );
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
