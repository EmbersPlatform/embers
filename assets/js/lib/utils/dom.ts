import Option from "./option";

const parser = new DOMParser();

export function parse(html) {
  const dom = parser.parseFromString(html, "text/html");

  if(dom.querySelector('parsererror')) {
    return Option.None;
  }
  return Option.Some(dom);
}
