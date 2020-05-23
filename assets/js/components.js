import { define } from "heresy";
import components from "./components/*/index.js";

export function init() {
  for(let name in components) {
    define(components[name].default);
  }
}
