/**
 * Hide the elements with `soft-kw-hide` class bar when an input is focused
 * to prevent the software keyboard of mobile devices from bringing the
 * navigation above the keyboard, covering the input and preventing the
 * user from seeing what it's being typed.
 *
 * There should be a better method to detect this.
 */

const input_types = ["INPUT", "TEXTAREA"];

// The events are being added to the document, so there should be no need to
// remove them.

document.addEventListener("focusin", function (event) {
  // @ts-ignore
  if (event.target && input_types.includes(event.target.nodeName)) {
    document.querySelectorAll(".soft-kw-hide").forEach(el => {
      if(el === event.target || el.contains(event.target)) return;
      el.classList.add("mobile-hidden");
    })
  }
})

document.addEventListener("focusout", function (event) {
  // @ts-ignore
  if (event.target && input_types.includes(event.target.nodeName)) {
    document.querySelectorAll(".soft-kw-hide").forEach(el => {
      el.classList.remove("mobile-hidden");
    })
  }
})
