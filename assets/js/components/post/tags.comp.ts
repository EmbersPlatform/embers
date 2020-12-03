import {html} from "heresy";
import PubSub from "pubsub-js";

import { Component } from "../component";
import * as Sets from "~js/lib/utils/sets";

/**
 * Shows the post tags, and updates them whenever a post:<id>.updated_tags
 * pubsub event is fired.
 *
 * It must be a descendant of a `.post` element with a `data-tags` attribute.
 */
class PostTags extends Component(HTMLElement) {
  static component = "PostTags";
  static tagName = "element";

  pubsub_tokens: string[] = [];
  tags: Set<string>;
  post_id: string;

  oninit() {
    const tag_nodes = this.closest<HTMLElement>(".post").dataset.tags;
    const tag_names = tag_nodes
      ? new Set(tag_nodes.split(" "))
      : new Set<string>();

    this.tags = tag_names;
    this.post_id = this.dataset.post_id;

    this.pubsub_tokens.push(
      PubSub.subscribe(`post:${this.post_id}.updated_tags`, this.update_tags.bind(this))
    )
  }

  update_tags(_topic: string, new_tags: Set<string>) {
    this.tags = new_tags;
    this.render();
  }

  ondisconnected() {
    for(let token in this.pubsub_tokens) {
      PubSub.unsubscribe(token);
    }
  }

  render() {
    const tags = Sets.map(this.tags, tag => html`
      <a href=${`/tag/${tag}`} class="tag" data-name=${tag}>#${tag}</span>
    `)

    this.html`
      ${Array.from(tags)}
    `
  }
}

export default PostTags;
