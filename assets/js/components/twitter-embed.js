import {define} from "uce";

define("twitter-embed", {
  init() {
    console.log(this, this.dataset.id)
    window.twttr.widgets.createTweet(
      this.dataset.id,
      this,
      {
        theme: "dark"
      }
    )
  },
})
