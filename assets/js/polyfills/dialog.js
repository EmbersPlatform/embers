
import dialogPolyfill from 'dialog-polyfill';

const observe_dialogs = mutations => {
  for (let mutation of mutations) {
    for (let new_node of mutation.addedNodes) {
      if (new_node.tagName === "DIALOG") {
        dialogPolyfill.registerDialog(new_node);
      }
    }
  }
}

const observer = new MutationObserver(observe_dialogs)

document.addEventListener("DOMContentLoaded", () => {
  document.querySelectorAll("dialog").forEach(dialogPolyfill.registerDialog);
  observer.observe(document.documentElement, { childList: true, subtree: true });
})
