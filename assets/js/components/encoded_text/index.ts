import { Component } from "~js/components/component";

export default class EncodedText extends Component(HTMLElement) {
  static tagName = "element";

  onconnected() {
    let parser = new DOMParser;
    let dom = parser.parseFromString(
        '<!doctype html><body>' + this.textContent,
        'text/html');
    this.textContent = dom.body.textContent;
  }
}
