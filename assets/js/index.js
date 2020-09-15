import "./modernizr";
import "./soft_keyboard";
import "./polyfills/dialog";
import "./lib/socket";
// import "./unpoly";

import * as Controllers from "./controllers";
import * as Components from "./components";

import * as Title from "./lib/title"
import * as Chat from "./lib/chat";

import "./managers";

import Pjax from "pjax-api";
import { register_modal } from "./components/moderation/post-report-dialog.comp";

Title.init();
Chat.connect();

Controllers.init();
Components.init();

window["pjax"] = new Pjax({
  areas: [
    '#board'
  ],
  filter: el => {
    return !el.matches("a[data-post-modal]")
  }
});

var _wr = function(type) {
	var orig = history[type];
	return function() {
		const rv = orig.apply(this, arguments);
    const e = new Event(type);
    // @ts-ignore
		e.arguments = arguments;
		window.dispatchEvent(e);
		return rv;
	};
};
history.pushState = _wr('pushState'), history.replaceState = _wr('replaceState');

document.addEventListener("DOMContentLoaded", () => {
  register_modal();
})
