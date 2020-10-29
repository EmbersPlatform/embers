import { html, render } from "uhtml";
import { define } from "wicked-elements";
import { Timer } from "~js/lib/utils/timer";
import { reactive, ref } from "./component";
import * as Fetch from "~js/lib/utils/fetch";
import { gettext } from "~js/lib/gettext";

define(".tag", {
  init() {
    const {element} = this;

    let timer;
    const state = reactive({
      loaded: false,
      loading: false,
      error: false,
      tag_data: null
    }, () => update())

    const start_timer = () => {
      if(timer) stop_timer();
      timer = new Timer(500, show_popup);
    }
    const stop_timer = () => {
      timer.pause();
    }

    const show_popup = () => {
      ref(element).popup.classList.add("open");
      if(!state.loaded) load_tag();
    }
    const hide_popup = () => {
      stop_timer();
      ref(element).popup.classList.remove("open");
    }

    const load_tag = async () => {
      state.loading = true;
      state.error = false;
      const res = await Fetch.get(`/tag/${element.dataset.name}`, {accept: "json"});
      switch(res.tag) {
        case "Success": {
          state.tag_data = await res.value.json();
          state.loaded = true;
          break;
        }
        default: {
          state.error = true;
          break;
        }
      }
      state.loading = false;
    }

    const update = () => {
      render(ref(element).popup, html`
        ${state.loading
          ? gettext("Loading tag...")
          : state.loaded
            ? html`
              <div class="tag-name">${state.tag_data.name}</div>
              <div class="tag-details">${
                state.tag_data.description || gettext("No description available")
              }</div>
            `
            : ``
        }
        ${state.error
          ? html`
            <p>${gettext("There was an error loading the tag")}</p>
            <button class="button" onclick=${load_tag}>${gettext("Retry")}</button>
          `
          : ``
        }
      `)
    }

    const popup = html.node`<div ref="popup"></div>`;

    element.appendChild(popup);

    const swallow_event = e => e.returnValue = false;

    element.addEventListener("mouseover", start_timer);
    element.addEventListener("mouseleave", hide_popup);
    element.addEventListener("blur", hide_popup);

    element.addEventListener("touchstart", swallow_event);
    element.addEventListener("touchend", swallow_event);
    element.addEventListener("touchmove", swallow_event);
    element.addEventListener("touchcancel", swallow_event);

    update();
  }
})
