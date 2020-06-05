import { valid_tag } from "~js/lib/posts/validations";
import { dgettext } from "~js/lib/gettext"
import { Component } from "~js/components/component";

export default class TagInput extends Component(HTMLInputElement) {
  static tagName = "input";

  tags: string[];
  placeholder: string;

  oninit() {
    this.tags = [];
    this.placeholder = dgettext("editor", "Tags, separated by spaces");
    this.addEventListener("input", this.on_input.bind(this));
  }

  on_input() {
    const tags_list = this.value.split(" ");
    this.tags = tags_list.filter(valid_tag);
    this.dispatch("update", this.tags);
  }
}
