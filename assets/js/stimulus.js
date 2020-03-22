import { Application } from "stimulus";
import CommentsController from "./controllers/comments";
import TimelineController from "./controllers/timeline";

export function init() {
  const application = Application.start();
  application.register("comments", CommentsController);
  application.register("timeline", TimelineController);

  return application;
}
