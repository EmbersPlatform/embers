import { define } from "uce";

define("mod-users-index", {
  extends: "div",

  props: {
    users_list: null
  },

  init() {
    this.props.users_list = this.querySelector("[users-list]");
  },

  render() {

  }
})
