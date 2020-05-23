export default {
  name: "EncodedText",
  extends: "element",

  onconnected() {
    let parser = new DOMParser;
    let dom = parser.parseFromString(
        '<!doctype html><body>' + this.textContent,
        'text/html');
    this.textContent = dom.body.textContent;
  }
}
