import { Component } from "~js/components/component";

export default class TwitterEmbed extends Component(HTMLElement) {
  static component = "TwitterEmbed";
  static tagName = "twitter-embed";

  onconnected() {
    // @ts-ignore
    window.twttr.widgets.createTweet(
      this.dataset.id,
      this,
      {
        theme: "dark"
      }
    )
    .then(() => {
      this.dispatch("medialoaded")
    })
  }
}

