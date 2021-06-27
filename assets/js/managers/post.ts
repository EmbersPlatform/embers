import ReactionsDialog from "~js/components/reactions_dialog/reactions_dialog.comp";
import SharePostDialog from "~js/components/share_post_dialog/share_post_dialog.comp";

let reactions_dialog: ReactionsDialog;
let share_dialog: SharePostDialog;

document.addEventListener("DOMContentLoaded", () => {
  reactions_dialog = register_element("reactions-dialog");
  share_dialog = register_element("share-post-dialog");
})

function register_element<T extends HTMLElement>(tag: string) {
  const dialog = document.createElement(tag) as T;
  document.body.append(dialog);
  return dialog;
}

export const show_reactions = (post_id: string) => {
  reactions_dialog.showModal(post_id);
}

export const share_post = (post_id: HTMLElement) => {
  share_dialog.showModal(post_id);
}
