import { Base } from "#/components/component";

import i18n from "#/lib/gettext";

import * as Links from "#/lib/links";

import union from "/js/lib/utils/union";

const States = union("States", {
  Idle: [],
  Processing: ["url"],
  Success: ["link"],
  Error: ["error"]
});

export default {
  ...Base,
  name: "LinkZone",
  extends: "div",

  mappedAttributes: ["status"],

  oninit() {
    this.status = States.Idle;
  },

  async add_link(url) {
    if(!this.status.is(States.Idle)) return;

    this.status = States.Processing(url);
    const res = await Links.process(url);
    res.match({
      Success: link => {
        console.log("link?", link)
        this.status = States.Success(link);
        this.dispatch("process", link.id);
      },
      Error: error => {
        this.status = States.Error(error);
        throw error;
      },
      NetworkError: () => {
        this.status = States.Error("Network Error");
      }
    })
  },

  reset() {
    this.status = States.Idle;
  },

  onstatus() {
    this.render();
  },

  onclick() {
    this.reset();
  },

  render() {
    this.status.cata({
      Idle: () => {
        this.html`${``}`;
      },
      Processing: () => {
        this.html`<p>${i18n.gettext("Processing link")}</p>`;
      },
      Success: () => {
        this.html`
          <button class="plain-button remove-link-button" onclick=${this}>${i18n.gettext("Remove link")}</button>
          ${{html: this.status.link.html}}
        `;
      },
      Error: () => {
        this.html`<p class="error">${i18n.gettext("Could not process the link")}</p>`;
      }
    })
  }
}
