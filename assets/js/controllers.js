import { Application } from "stimulus";

// @ts-ignore
import controllers from "./controllers/*/index.ts";

export function init() {
  const application = Application.start();

  for(let c in controllers) {
    let {name, default: controller} = controllers[c];
    application.register(name, controller);
  }

  return application;
}
