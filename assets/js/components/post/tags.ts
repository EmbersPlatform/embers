import {html} from "heresy";
import PubSub from "pubsub-js";

import { Component } from "../component";
import * as Sets from "~js/lib/utils/sets";

class PostTags extends Component(HTMLElement) {
  static tagName = "element";

  pubsub_tokens: string[] = []
  tags: Set<string>
  post_id: string

  oninit() {
    const tag_nodes = this.querySelectorAll("post-tag");
    const tag_nodes_set = Sets.from(tag_nodes);
    const tag_names = Sets.map(tag_nodes_set, elem => elem.textContent);

    this.tags = tag_names;
    this.post_id = this.dataset.post_id;

    this.pubsub_tokens.push(
      PubSub.subscribe(`post:${this.post_id}.updated_tags`, this.update_tags.bind(this))
    )
  }

  /**
   *
   * @param {string} _topic
   * @param {Set<string>} new_tags
   */
  update_tags(_topic, new_tags) {
    this.tags = new_tags;
    this.render();
  }

  ondisconnected() {
    for(let token in this.pubsub_tokens) {
      PubSub.unsubscribe(token);
    }
  }

  render() {
    this.html`
      ${Sets.to_array(
          Sets.map(this.tags, tag => html`
            <span class="tag">#${tag}</span>
          `)
        )}
    `
  }
}

export default PostTags;
