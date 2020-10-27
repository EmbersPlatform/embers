import { define } from "wicked-elements";
import { confirm } from "~js/managers/dialog";
import { gettext } from "~js/lib/gettext";
import status_toasts from "~js/managers/status_toasts";

define("[disabled-posts]", {
  // @ts-ignore
  onClick(event: MouseEvent) {
    const target = event.target as HTMLElement;
    switch(target.dataset.action) {
      case "prune": {
        prune();
        break;
      }
    }
  }
})

const prune = async () => {
  const confirmed = await confirm({
    title: gettext("Prune disabled posts?"),
    text: gettext("This action can't be undone")
  })

  if(!confirmed) return;

  status_toasts.add({
    content: gettext("Not implemented yet"),
    classes: ["danger"]
  })
}
