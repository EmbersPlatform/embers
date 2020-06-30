import { html } from "heresy";
import { Component } from "~js/components/component";

import i18n from "~js/lib/gettext";

import * as Links from "~js/lib/links";
import type {Link} from "~js/lib/links";

type State =
  | {tag: "Idle"}
  | {tag: "Processing", value: string}
  | {tag: "Success", value: Link}
  | {tag: "Error", value: Object}

export default class LinkZone extends Component(HTMLDivElement) {
  static component = "LinkZone";

  static tagName = "div";

  static mappedAttributes = ["state"];

  state: State = {tag: "Idle"};

  async add_link(url) {
    if(this.state.tag !== "Idle") return

    this.state = {tag: "Processing", value: url};
    const res = await Links.process(url);
    switch(res.tag) {
      case "Success": {
        const link = res.value;
        this.state = {tag: "Success", value: link};
        this.dispatch("process", link.id);
        break;
      }
      case "Error": {
        const error = res.value;
        this.state = {tag: "Error", value: error};
        throw error;
      }
      case "NetworkError": {
        this.state = {tag: "Error", value: "Network Error"};
        break;
      }
    }
  }

  reset() {
    this.state = {tag: "Idle"};
  }

  onstate() {
    this.render();
  }

  render() {
    const reset = () => this.reset();

    switch(this.state.tag) {
      case "Idle": {
        this.html`${``}`;
        break;
      }
      case "Processing": {
        this.html`<p>${i18n.gettext("Processing link")}</p>`
        break;
      }
      case "Success": {
        this.html`
          <button class="plain-button remove-link-button" onclick=${reset}>${i18n.gettext("Remove link")}</button>
          ${{html: this.state.value.html}}
        `;
        break;
      }
      case "Error": {
        this.html`<p class="error">${i18n.gettext("Could not process the link")}</p>`;
        break;
      }
    }
  }
}
