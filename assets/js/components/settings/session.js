import { html } from "uhtml";
import { define } from "wicked-elements";
import { confirm, show_dialog } from "~js/managers/dialog";

define("[subview=security]", {
  connected() {
    // @ts-ignore
    this.element.addEventListener("click", this);
  },

  // @ts-ignore
  handleEvent: async function (event) {
    console.log(event.target);
    if (event.target.matches("[data-action=confirm_delete]")) {
      const confirmation = await confirm({
        text: "Are you sure you want to delete this session?",
      });

      if (confirmation) {
        // @ts-ignore
        const token = event.target.closest(".session").dataset.token;
        // @ts-ignore
        this.element.dispatchEvent(
          new CustomEvent("confirm_delete", { detail: { token } })
        );
      }
    }

    if (event.target.matches("[data-action=confirm_close_all]")) {
      const confirmation = await confirm({
        text: "Are you sure you want to close all sessions?",
      });

      if (confirmation) {
        // @ts-ignore
        this.element.dispatchEvent(new CustomEvent("close_all"));
      }
    }
  },
});
