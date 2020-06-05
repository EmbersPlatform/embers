import { Application } from "stimulus";

import controllers from "./controllers/*/index.ts";

console.log(controllers)

export function init() {
  const application = Application.start();

  for(let c in controllers) {
    let {name, default: controller} = controllers[c];
    application.register(name, controller);
  }

  return application;
}
