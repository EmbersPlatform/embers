import Vue from "vue";
import VueRouter from "vue-router";
import {
  baseUrl
} from "@/config";
import routes from "./routes";
import store from "@/store";

Vue.use(VueRouter);

const router = new VueRouter({
  routes,
  mode: "history",
  base: baseUrl,
  linkActiveClass: "active",

  scrollBehavior(to, from, savedPosition) {
    if (savedPosition) {
      return savedPosition;
    } else {
      return {
        x: 0,
        y: 0
      };
    }
  }
});

router.afterEach(route => {
  store.dispatch("title/update", route.meta.title ? route.meta.title : "Embers");

  if (!route.meta.noSuffix) {
    store.dispatch("title/update", route.meta.title + " · Embers");
  }
});

router.mode = "html5";
export default router;
