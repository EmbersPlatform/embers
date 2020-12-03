import { define } from "wicked-elements";
import * as Fetch from "~js/lib/utils/fetch";
import { ban_user_dialog } from "../moderation/ban-user-dialog.comp";

define(".disabled-post", {
  init() {
    this.post = this.element.querySelector(".post");
  },
  // @ts-ignore
  onClick(event) {
    const target = event.target as HTMLElement;
    switch(target.dataset.action) {
      case "restore": {
        delete_post(this);
        break;
      }
      case "ban-user": {
        ban_user(this)
        break;
      }
    }
  }
});

const deleting = new WeakMap();
const delete_post = async (host) => {
  if(deleting.get(host)) return;

  deleting.set(host, true);

  const post_id: string = host.post.dataset.postId;
  const res = await Fetch.put(`/moderation/disabled_posts/${post_id}/restore`);
  if(res.tag === "Success") {
    host.element.remove();
  }

  deleting.set(host, false);
}

const ban_user = async (host) => {
  ban_user_dialog.showModal(host.post.dataset.author);
}
