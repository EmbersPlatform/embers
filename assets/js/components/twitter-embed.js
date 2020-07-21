import {define} from "uce";
import EventBus from "../lib/event_bus"

define("twitter-embed", {
  init() {
    window.twttr.widgets.createTweet(
      this.dataset.id,
      this,
      {
        theme: "dark"
      }
    )
    .then(() => {
      EventBus.$emit("medialoaded")
    })
  },
})
