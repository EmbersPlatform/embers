import { html } from "uhtml";
import ConfirmDialog from "~js/components/confirm_dialog/dialog.comp";

type Contents = string | HTMLElement | DocumentFragment;
interface ConfirmOptions {
  title?: Contents,
  text?: Contents
}

export const confirm = (contents: ConfirmOptions) => new Promise((resolve, _reject) => {
  const accept = () => {
    resolve(true);
    dialog.remove();
  }
  const cancel = () => {
    resolve(false);
    dialog.remove();
  }

  const dialog = html.node`
  <confirm-dialog padded onaccept=${accept} oncancel=${cancel}>
    <p>${contents.title ? contents.title : ``}</p>
    <p>${contents.text ? contents.text : ``}</p>
  </confirm-dialog>
  ` as ConfirmDialog;

  document.body.append(dialog);
  dialog.showModal();
});
