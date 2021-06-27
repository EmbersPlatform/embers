import "./modernizr";
import "./soft_keyboard";
import "./polyfills/dialog";
import "./lib/socket";

import * as Controllers from "./controllers";
import * as Components from "./components";

import * as Title from "./lib/title";
import * as Chat from "./lib/chat";

import "./managers";

import Pjax from "pjax-api";
import { register_modal } from "./components/moderation/post-report-dialog.comp";
import * as BanUserDialog from "./components/moderation/ban-user-dialog.comp";
import "./managers/status_toasts";
import "./managers/general_toasts";

import topbar from "topbar";

// Show progress bar on live navigation and form submits
topbar.config({
  barColors: { 0: "#eb3d2d" },
  shadowColor: "rgba(0, 0, 0, .3)",
});
window.addEventListener("phx:page-loading-start", (info) => topbar.show());
window.addEventListener("phx:page-loading-stop", (info) => topbar.hide());

Title.init();
Chat.connect();

Controllers.init();
Components.init();

window["pjax"] = new Pjax({
  areas: ["#board"],
  filter: (el) => {
    return (
      !el.matches("a[data-post-modal]") &&
      !el.matches("[target=_blank]") &&
      !el.matches("[data-phx-link]")
    );
  },
});

var _wr = function (type) {
  var orig = history[type];
  return function () {
    const rv = orig.apply(this, arguments);
    const e = new Event(type);
    // @ts-ignore
    e.arguments = arguments;
    window.dispatchEvent(e);
    return rv;
  };
};
(history.pushState = _wr("pushState")),
  (history.replaceState = _wr("replaceState"));

document.addEventListener("DOMContentLoaded", () => {
  register_modal();
  BanUserDialog.register_modal();
});

window.addEventListener("pjax:fetch", (e) => {
  topbar.show();
});

window.addEventListener("pjax:unload", () => {
  topbar.hide();
});
