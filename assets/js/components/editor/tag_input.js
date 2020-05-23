import { valid_tag } from "#/lib/posts/validations";
import i18n from "#/lib/gettext"

import { Base } from "#/components/component";

export default {
  ...Base,
  name: "TagInput",
  extends: "input",

  oninit() {
    this.tags = [];
    this.placeholder = i18n.dgettext("editor", "Tags, separated by spaces");
    this.addEventListener("input", this);
  },

  oninput() {
    const tags_list = this.value.split(" ")
    this.tags = tags_list.filter(valid_tag)
    this.dispatch("update", this.tags);
  }
}
