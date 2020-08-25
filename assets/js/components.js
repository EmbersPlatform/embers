import { register } from "./components/component";
// @ts-ignore
import components from "./components/**/*.comp.ts";

import "./components/infinite-scroll";
import "./components/top-bar";

const traverse_module = (module) => {
  if(module.__esModule) {
    register(module.default)
  } else {
    for(let name in module) {
      traverse_module(module[name])
    }
  }
}

export function init() {
  traverse_module(components)
}

