import { Application } from "stimulus";

import controllers from "./controllers/*.js";

export function init() {
  const application = Application.start();

  for(let c in controllers) {
    let {name, default: controller} = controllers[c];
    application.register(name, controller);
  }

  return application;
}
