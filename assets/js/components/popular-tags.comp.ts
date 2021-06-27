import { html } from "heresy";
import { Component } from "./component";
import { gettext } from "~js/lib/gettext";

import * as Fetch from "~js/lib/utils/fetch";

type TagData = {
  count: number;
  tag: {
    id: string;
    name: string;
    description: string;
    sub_level: number;
  };
};

async function fetch_tags() {
  const res = await Fetch.get("/tags/popular");
  if (res.tag === "Success") {
    return await res.value.json();
  }
}

export default class extends Component(HTMLElement) {
  static component = "PopularTags";

  tags: TagData[] = [];

  async onconnected() {
    this.tags = await fetch_tags();
    this.render();
  }

  render() {
    this.html`
    <header>
      <span>${gettext("Popular tags")}</span>
    </header>
    <ul>
      ${this.tags.map(
        (tag) => html`
          <li>
            <a href=${`/tag/${tag.tag.name}`} title=${tag.tag.name}>
              <p class="tag-name">#${tag.tag.name}</p>
              ${tag.tag.description
                ? html`<p class="tag-misc">${tag.tag.description}</p>`
                : ``}
              <p class="tag-count tag-misc">${gettext(`${tag.count} posts`)}</p>
            </a>
          </li>
        `
      )}
    </ul>
    `;
  }
}
