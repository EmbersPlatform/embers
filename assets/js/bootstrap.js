console.info(
  "%c Embers %c Red social basada en la comunidad ",
  "padding: 2px; color: #fff; background-color: #eb3d2d; border-radius: 2px 0 0 2px;",
  "padding: 2px; color: #fff; background-color: #333; border-radius: 0 2px 2px 0;"
);

import "@/lib/socket";
import "@/lib/socket/presence";
import _socket from "./lib/socket";

import autosize from "autosize";
import axios from "axios";
import moment from "moment";

import Vue from "vue";
import VueInfiniteScroll from "vue-infinite-scroll";

import * as svgicon from "vue-svgicon";
import {
  VueMasonryPlugin
} from "vue-masonry";

import VModal from "vue-js-modal";
Vue.use(VModal, {
  dynamic: true,
  dialog: true
});

import Notifications from "vue-notification";
Vue.use(Notifications);

Vue.use(require("vue-shortkey"));

import v_visible from "./directives/v_visible";
Vue.use(v_visible);

import VueMq from "vue-mq";

Vue.use(VueMq, {
  breakpoints: {
    sm: 644,
    md: 1250,
    lg: Infinity
  }
});

import {
  sync
} from "vuex-router-sync";

import router from "./router";
import store from "./store";

require("moment/locale/es");

Vue.use(VueInfiniteScroll);
require("../compiled-icons");
Vue.use(svgicon);
Vue.use(VueMasonryPlugin);

Object.defineProperties(Vue.prototype, {
  $moment: {
    get: function () {
      return moment;
    }
  }
});

Vue.filter("truncate", function (text, stop, clamp) {
  return text.slice(0, stop) + (stop < text.length ? clamp || "..." : "");
});

/**
 * Store dispatchers
 */
store.dispatch("setAppData", window.appData);
store.dispatch("updateUser", window.appData.user);
store.dispatch("tag/update", window.appData.tags);
store.dispatch("notifications/update", window.appData.notifications);

if (window.appData.user !== null) {
  store.dispatch("initNotifications", window.appData.user.unreadNotifications);
  store.dispatch(
    "chat/updateUnreadMessagesCount",
    window.appData.user.unreadChatMessages
  );
  store.dispatch("updateSettings", window.appData.user.settings);
}

sync(store, router);

/**
 * Add X-CSRF-Token header to every API call
 */
axios.interceptors.request.use(function (config) {
  config.headers.common["X-CSRF-Token"] = window.appData.csrfToken;
  return config;
});

/**
 * Handle promise rejections
 */
window.addEventListener("unhandledrejection", function (event) {
  if (
    typeof event === "object" &&
    typeof (event.reason || event.detail.reason).instanceOfApiError !==
    "undefined"
  ) {
    // unhandled API error
    // don't log this event on the browser console
    event.preventDefault();

    // display a message to the user with the original error message
    app.$notify({
      group: "top",
      text: event.reason || event.detail.reason,
      type: "error"
    });
  }
});

$(document).ready(function () {
  $("#loader").remove();

  // /**
  //  * Autoresize text inputs
  //  */
  $(document).on("focus", "[data-autoresize]", function () {
    autosize($("[data-autoresize]"));
  });

  /**
   * Internal route anchors
   */
  $(document).on("click", "[data-internal-route]", function (event) {
    event.preventDefault();
    app.$router.push($(this).data("internal-route"));
  });
});
