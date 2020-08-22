import { define } from "heresy";
// @ts-ignore
import components from "./components/**/*.comp.ts";

import "./components/infinite-scroll";

const register = component => {
  // Hack, since class names get transpiled and the name property can't
  // be overriden, just dinamically set it to whatever the static `component`
  // property is.
  // Why the hell are class names minified anyways?
  const name = component.component;
  Object.defineProperty(component, 'name', {
    writable: true,
    value: name
  });
  define(component)
}

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

