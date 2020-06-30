import { define } from "heresy";
// @ts-ignore
import components from "./components/*/index.ts";

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

import PostTags from "./components/post/tags";
import PostFavButton from "./components/post/favorite-button";
import PostActions from "./components/post/post_actions";
import PostViewerModal from "./components/post/post-viewer-modal";

import ENotification from "./components/notifications_panel/notification";
import NotificationsBell from "./components/notifications_panel/notifications-bell";

export function init() {
  for(let name in components) {
    register(components[name].default);
  }
  register(PostTags);
  register(PostFavButton);
  register(PostActions);
  register(PostViewerModal);

  register(ENotification);
  register(NotificationsBell);
}

