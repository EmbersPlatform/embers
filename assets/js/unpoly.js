// @ts-nocheck
import "unpoly/dist/unpoly.min.js";
import "unpoly/dist/unpoly.min.css";

window.up.modal.config.openDuration = 0;
window.up.modal.config.closeDuration = 0;
window.up.modal.config.template = `
  <div class="custom-dialog up-modal">
    <dialog class="up-modal-dialog" open>
      <dialog-backdrop up-close></dialog-backdrop>
      <dialog-box class="up-modal-content"></dialog-box>
    </dialog>
  </div>
`;

function is_same_origin_anchor(anchor) {
  if(anchor.target == "_blank") return false;

  const href = new URL(anchor.href);
  if(href.origin !== location.origin) return false;

  return true;
}

document.addEventListener("click", event => {
  // Perform an Unpoly follow on links in the same origin
  const anchor = event.target.closest("a");
  if(!anchor) return;
  if(anchor.hasAttribute("up-target")) return;
  if(anchor.hasAttribute("data-post-modal")) return;
  if(!is_same_origin_anchor(anchor)) return;

  event.preventDefault();
  window.up.follow(anchor, {target: "#embers"});
})
