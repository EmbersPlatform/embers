import "./bootstrap";

import Vue from "vue";
import App from "./App.vue";
import router from "./router";
import store from "./store";

const app = new Vue({
  router,
  store,

  components: { App },

  data() {
    return {
      baseUrl: window.baseUrl,
      moment: Vue.moment
    };
  }
}).$mount("app");

// HACK
window.app = app;
