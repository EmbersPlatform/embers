import { define } from "wicked-elements";
import { html, render } from "uhtml";
import { reactive } from "../component";
import * as Channel from "~js/lib/socket/channel";

define("[reports-button]", {
  async init() {
    const update = () => {
      const count_text = state.count > 99 ? "+99" : state.count.toString();

      render(this.element, html`
        ${contents}
        <span
          class=${`counter ${state.count <= 0 ? "hidden" : ""}`}
        >${count_text}</span>
      `)

      this.element.title =
        state.count > 0
        ? `${state.count} pending reports`
        : `No pending reports`
    }

    const contents = [].slice.call(this.element.children);

    const state = reactive({
      count: 0
    }, update);

    state.count = parseInt(this.element.getAttribute("count"));

    this.channel_subs = [
      await Channel.subscribe("mod", "report_count_update", (data) => {
        state.count = data.count
      })
    ]

    update();
  },
  disconnected() {
    this.channel_subs.forEach(Channel.unsubscribe);
  }
})

