import { html, render } from "uhtml";
import ConfirmDialog from "~js/components/confirm_dialog/dialog.comp";
import type ModalDialog from "~js/components/dialog/dialog.comp";

type Content =
  | string
  | HTMLElement
  | DocumentFragment
  | ReturnType<typeof html>;
type ContentClosure = (accept: Function, cancel: Function) => Content;

type Contents = Content | ContentClosure;

interface ConfirmOptions {
  title?: Contents;
  text?: Contents;
}

export const confirm = (contents: ConfirmOptions) =>
  new Promise((resolve, _reject) => {
    const accept = () => {
      resolve(true);
      dialog.remove();
    };
    const cancel = () => {
      resolve(false);
      dialog.remove();
    };

    const dialog = html.node`
  <confirm-dialog padded onaccept=${accept} oncancel=${cancel}>
    <p class="confirm-dialog-title">${
      contents.title
        ? typeof contents.title === "function"
          ? contents.title(accept, cancel)
          : contents.title
        : ``
    }</p>
    <p class="confirm-dialog-content">${
      contents.text
        ? typeof contents.text === "function"
          ? contents.text(accept, cancel)
          : contents.text
        : ``
    }</p>
  </confirm-dialog>
  ` as ConfirmDialog;

    document.body.append(dialog);
    dialog.showModal();
  });

type DialogContent = HTMLElement | ReturnType<typeof html>;
type DialogCallback = (dialog: ModalDialog, close: () => void) => DialogContent;

/**
 * Creates and displays a modal dialog.
 *
 * @param contents The contents to be rendered in the dialog. It can be an
 * HTMLElement, a uhtml Hole, or a function that returns either of those. If it's
 * a function, the dialog itself will be passed as first argument, and a
 * function to close it as second argument.
 */
export const show_dialog = (contents: DialogCallback) => {
  const close = () => dialog.remove();

  const dialog = html.node`<modal-dialog padded onclose=${close}></modal-dialog>` as ModalDialog;

  // We need to render into the dialog separately so we can pass the dialog as
  // an argument to the content closure.
  // The dialog will pick the contents after it's connectedCallback, and that
  // happens after inserting it to the DOM, so this approach will work properly.
  render(
    dialog,
    contents
      ? typeof contents === "function"
        ? contents(dialog, close)
        : contents
      : null
  );

  document.body.append(dialog);
  dialog.showModal();
};
