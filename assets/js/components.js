import { register } from "./components/component";
// @ts-ignore
import components from "./components/**/*.comp.ts";

import "./components/infinite-scroll";
import "./components/top-bar";
import "./components/moderation/post-report-summary";
import "./components/moderation/reports-counter";
import "./components/moderation/ban-summary";
import "./components/moderation/users/mod-users-index";
import "./components/moderation/users/user-summary";
import "./components/moderation/users/mod-manage-user";
import "./components/moderation/roles/mod-roles-index";
import "./components/moderation/roles/mod-role";
import "./components/deleted_posts/disabled_post";
import "./components/deleted_posts/disabled_posts";
import "./components/post/post";

import "./components/pinned-tags";
import "./components/show-tag-page";
import "./components/update-tag";
import "./components/tag";
import "./components/mention";
import "./components/post-id-link";

import "./components/media-gif";

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

