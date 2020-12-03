import { get_settings } from "~js/lib/application";
import * as Sets from "~js/lib/utils/sets";
import { gettext } from "~js/lib/gettext";

export const parse = (html) => {
  return document.createRange().createContextualFragment(html)
    .firstChild as HTMLElement;
};

export const replace_with_tombstone = (post) => {
  post.outerHTML = `
    <div class="post-tombstone">
      ${gettext("This post is no longer available")}
    </div>
  `;
  return post;
};

type TagsList = string[] | Set<string>;
export const update_tags = (
  post: HTMLElement,
  new_tags: TagsList
): HTMLElement => {
  if (new_tags instanceof Array) {
    new_tags = Sets.from<string>(new_tags);
  }

  post.dataset.tags = Sets.join(new_tags, " ");

  post = format_content_warning(post);

  return post;
};

export function is_nsfw(post) {
  const tags = get_tags(post);
  return Sets.has_insensitive(tags, "nsfw");
}

export const format_content_warning = (post: HTMLElement): HTMLElement => {
  console.debug(post);
  const tags = get_tags(post);
  let controllers = new Set(post.dataset.controller.split(" "));

  switch (get_settings().content_nsfw) {
    case "hide": {
      if (Sets.has_insensitive(tags, "nsfw")) {
        controllers.add("content-warning");
        post.setAttribute("nsfw", "true");
      }
      break;
    }
    case "ask": {
      if (Sets.has_insensitive(tags, "nsfw")) {
        controllers.add("content-warning");
        post.setAttribute("nsfw", "true");
      } else {
        controllers.delete("content-warning");
        post.removeAttribute("nsfw");
      }
      break;
    }
    case "show": {
      controllers.delete("content-warning");
      post.removeAttribute("nsfw");
      break;
    }
  }

  post.dataset.controller = Sets.join(controllers, " ");

  return post;
};

export const get_tags = (post: HTMLElement): Set<string> => {
  return Sets.from(post.dataset.tags.split(" "));
};
