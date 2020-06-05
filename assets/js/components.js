import { define } from "heresy";
import components from "./components/*/index.ts";

import PostTags from "./components/post/tags";
import PostFavButton from "./components/post/favorite-button";

export function init() {
  for(let name in components) {
    define(components[name].default);
  }
}

define(PostTags);
define(PostFavButton);
