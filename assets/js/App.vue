<template>
  <div
    id="appex"
    :class="{'in-app': isApp, 'blur': (blurToolBox || blurSidebar), 'fixed': fixed}"
    :dark-side="openSidebar"
    ref="main"
  >
    <template v-if="ready">
      <template v-if="isApp">
        <Navigation v-if="user"></Navigation>
        <Sticky v-else class="in-app"></Sticky>
        <Main></Main>
        <div v-if="toHeaven || isNewActivity" class="signals">
          <button
            v-if="isNewActivity"
            @click.prevent="refreshFeed"
            class="new-activity"
            data-tip="Nueva actividad"
            data-tip-position="left"
            data-tip-text
          >{{newActivityText}}</button>
          <button
            v-if="toHeaven"
            @click.prevent="toTop"
            data-tip="Ir al cielo"
            data-tip-position="left"
            data-tip-text
          >
            <svgicon name="n_left-sign"></svgicon>
          </button>
        </div>
      </template>
      <template v-else>
        <Sticky></Sticky>
        <router-view></router-view>
      </template>
    </template>
    <modals-container/>
    <v-dialog/>
    <notifications group="top" position="top center" :max="3">
      <template slot="body" slot-scope="props">
        <notification :props="props"/>
      </template>
    </notifications>
    <notifications
      group="activity"
      :position="($mq == 'sm') ? 'bottom center' : 'bottom right'"
      :max="5"
    >
      <template slot="body" slot-scope="props">
        <notification :props="props"/>
      </template>
    </notifications>
    <rules-modal/>
    <new-post-modal v-if="show_new_post_modal" :related="new_post_modal_related"/>
  </div>
</template>

<script>
import Navigation from "./layout/Navigation";
import Main from "./layout/Main";
import Sticky from "./layout/Sticky";
import { mapGetters } from "vuex";
import userResource from "./api/user";
import _ from "lodash";
import Hammer from "hammerjs";

import RulesModal from "./components/Modals/RulesModal";
import NewPostModal from "./components/Modals/NewPostModal";

import Notification from "./components/Notification";

import { Presence } from "phoenix";
import socket from "./lib/socket";

import EventBus from "./lib/event_bus";

export default {
  components: {
    Navigation,
    Main,
    Sticky,
    Notification,
    RulesModal,
    NewPostModal
  },
  data() {
    return {
      ready: true,
      searchParams: "",
      newMessageTitle: false,
      newMessageTitleInterval: null,
      toHeaven: false,
      blurToolBox: false,
      blurSidebar: false,
      openSidebar: false,
      fixed: false,
      show_new_post_modal: false,
      new_post_modal_related: null
    };
  },
  methods: {
    toTop() {
      $("html, body").animate({ scrollTop: 0 }, 500, "swing");
    },
    refreshFeed() {
      this.toTop();
      this.$store.dispatch("prepend_new_posts");
      this.$store.dispatch("resetNewActivity");
    }
  },
  computed: {
    ...mapGetters({
      user: "user",
      notifications_count: "notifications_count",
      title: "title",
      newActivity: "newActivity"
    }),
    ...mapGetters("chat", ["new_message", "online_friends"]),
    isApp: function() {
      switch (this.$route.name) {
        case "rules":
        case "faq":
        case "acknowledgment":
        case "login":
        case "register":
        case "reset":
        case "404":
          return false;
          break;
        default:
          return true;
          break;
      }
    },
    newActivityText() {
      let posts = this.newActivity;
      if (posts > 9) {
        return "+9";
      }
      return posts;
    },
    isNewActivity() {
      switch (this.$route.matched[0].name) {
        case "home":
          return this.newActivity > 0;
          break;
        default:
          return false;
          break;
      }
    }
  },
  created() {
    // Handle search dynamic title
    document.title = this.title;
    this.searchParams = this.$route.params.searchParams;
    this.$root.$on("search-update", params => {
      this.searchParams = params;
    });

    window.addEventListener(
      "scroll",
      _.throttle(() => {
        this.toHeaven = $(window).scrollTop() >= 300;
      }),
      1000
    );
    this.$root.$on("blurToolBox", data => {
      this.blurToolBox = data;
    });
    this.$root.$on("blurSidebar", data => {
      this.blurSidebar = data;
    });
    this.$root.$on("toggleSidebar", () => {
      this.openSidebar = !this.openSidebar;
    });
    this.$root.$on("openSidebar", () => {
      this.openSidebar = true;
    });
    this.$root.$on("closeSidebar", () => {
      this.openSidebar = false;
    });
    this.$root.$on("fixed", () => {
      this.fixed = !this.fixed;
    });

    window.addEventListener("storage", e => {
      const key = e.key;
      if (key === "newMessages") {
        this.$store.dispatch("chat/newMessage", e.newValue, false);
      }
      if (key === "unreadMessagesCount") {
        this.$store.dispatch(
          "chat/updateUnreadMessagesCount",
          e.newValue,
          false
        );
      }
    });

    let user_id = window.appData.user.id;

    let feed_channel = socket.channel(`feed:${user_id}`, {});
    feed_channel.join();
    feed_channel.on("new_activity", payload => {
      let post = payload.post;
      post.new = true;
      EventBus.$emit("new_activity", post);
    });

    EventBus.$on("new_activity", post => {
      this.$store.dispatch("add_new_post", post);
      this.$store.dispatch("newActivity");
    });

    EventBus.$on("show_new_post_modal", props => {
      this.show_new_post_modal = true;
      this.new_post_modal_related = props.related || null;
    });
    EventBus.$on("close_new_post_modal", props => {
      this.show_new_post_modal = false;
      this.new_post_modal_related = null;
    });
  },
  mounted() {
    /**
     * Hammer.js gestures
     *
     * Note that #apex is the top most parent of the application markup, so
     * child components need to stop their propagation in order to work properly
     */
    delete Hammer.defaults.cssProps.userSelect; // http://hammerjs.github.io/tips/ “I can’t select my text anymore!”
    let hmMain = new Hammer(this.$refs.main);
    hmMain.on("swiperight", event => {
      this.$root.$emit("openSidebar");
    });
    hmMain.on("swipeleft", event => {
      this.$root.$emit("closeSidebar");
    });
  },
  watch: {
    notifications_count: function() {
      this.$store.dispatch("updateTitle");
    },
    title(val) {
      document.title = val;
    },
    new_message() {
      if (this.new_message) {
        this.newMessageTitleInterval = setInterval(() => {
          const title =
            this.title === document.title
              ? "Tienes mensajes sin leer"
              : this.title;
          document.title = title;
        }, 1500);
      } else {
        clearInterval(this.newMessageTitleInterval);
        document.title = this.title;
      }
    }
  },
  beforeDestroy() {
    window.removeEventListener("scroll");
  }
};
</script>
