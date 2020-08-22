import { html } from "heresy";
import { Component } from "./component";
import { gettext } from "~js/lib/gettext";

import * as Fetch from "~js/lib/utils/fetch";

async function fetch_tags() {
  const res = await Fetch.get("/tags/popular");
  if(res.tag === "Success") {
    return await res.value.json();
  }
}

export default class extends Component(HTMLElement) {
  static component = "PopularTags";

  tags = [];

  async onconnected() {
    this.tags = await fetch_tags();
    this.render();
  }

  render() {
    this.html`
    <header>${gettext("Popular tags")}</header>
    <ul>
      ${this.tags.map(tag => html`
        <li>
          <a href=${`/tag/${tag.tag.name}`}>
            <span class="tag-name">#${tag.tag.name}</span>
            <span class="tag-count">${gettext(`${tag.count} posts`)}</span>
          </a>
        </li>
      `)}
    </ul>
    `
  }
}
