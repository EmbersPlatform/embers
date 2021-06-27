import { Component } from "./component";
import markdown from "~js/lib/markdown";

export default class LegMarkdown extends Component(HTMLElement) {
  static component = "LegMarkdown";

  content: string;

  onconnected() {
    this.content = markdown(this.textContent);
  }

  render() {
    this.innerHTML = this.content;
  }
}
