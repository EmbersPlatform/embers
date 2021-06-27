import s from "flyd";
import {unseen_count} from "~js/lib/notifications";

let base_title = s.stream<string>();

let flash_message = s.stream<string>();
let flash_interval = s.stream<number>();

let title = s.combine((base, unseen_count) => {
  return unseen_count() > 0
    ? `(${unseen_count()}) ${base()}`
    : `${base()}`
}, [base_title, unseen_count])

s.on((title) => {
  if(document.title != flash_message())
  document.title = title;
}, title)

export function init() {
  document.addEventListener("DOMContentLoaded", () => {
    base_title(document.title);

    // For some reason, when Unpoly updates the title, the MutationObserver
    // doesn't catch the change, so we have to observe the full head and see if
    // the title was affected
    const title_el = document.querySelector('title');
    const head_el = document.querySelector('head');
    const mo = new MutationObserver(muts => {
      for(let mut of muts) {
        if(  mut.target == title_el
          && document.title != title()
          && document.title != flash_message()
        ) {
          base_title(document.title);
        }
      }
    });
    mo.observe(head_el, {childList: true, subtree: true, characterData: true});
  });
}

export function flash(message) {
  flash_message(message);
  flash_interval(setInterval(() => {
    document.title == title()
      ? document.title = flash_message()
      : document.title = title()
  }, 1000))
}

export function stop_flash() {
  if(title()) {
    document.title = title()
  }
  clearInterval(flash_interval());
}
