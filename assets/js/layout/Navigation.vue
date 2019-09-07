<template>
  <nav id="navigation" v-if="show">
    <h1 id="logo">
      <router-link to="/" exact>
        <img v-if="efemerides" :src="`${efemerides.img}`" :title="efemerides.desc" />
        <svgicon name="elogo" v-else></svgicon>
      </router-link>
    </h1>
    <ul id="nav_open" class="nav-icon hidden">
      <li class="nav-icon">
        <span @click="switchSidebar()">
          <svgicon name="n_hamburguer"></svgicon>
        </span>
      </li>
    </ul>
    <ul id="nav_page" class="nav-icon">
      <li :class="{'active' : $route.path == '/'}" data-tip="inicio" data-tip-position="right">
        <router-link to="/" class="page" exact>
          <svgicon name="n_home"></svgicon>
        </router-link>
      </li>
      <li
        :class="{'active' : $route.path == '/discover'}"
        data-tip="descubre"
        data-tip-position="right"
      >
        <router-link to="/discover" class="page">
          <svgicon name="n_discover"></svgicon>
        </router-link>
      </li>
    </ul>
    <ul id="nav_dropdown" data-name="notificaciones" ref="notif" :class="{active: show_notif}">
      <notifications v-if="show_notif"></notifications>
    </ul>
    <ul id="nav_alerts" class="nav-icon">
      <li
        class="not-vex"
        :class="{'open': show_notif, 'alert': n_notif}"
        data-tip="notificaciones"
        data-tip-position="right"
      >
        <a ref="trg_notif">
          <svgicon name="n_alert"></svgicon>
        </a>
      </li>
      <!-- no hay matching de sub rutas ej: chat/2 TODO figure out how? -->
      <li
        :class="{'active' : $route.path == '/chat', 'alert': are_unread_notifications}"
        class="page not-vex"
        data-tip="mensajes"
        data-tip-position="right"
      >
        <router-link to="/chat" @click="readMessages">
          <svgicon name="n_inbox"></svgicon>
        </router-link>
      </li>
    </ul>
    <ul id="nav_user" class="nav-icon">
      <li class="hidden">
        <span @click="switchSidebar()">
          <svgicon name="n_left-sign"></svgicon>
        </span>
      </li>
      <li
        id="nav_user_pic"
        :class="{active: show_userMenu}"
        :data-user="isUser"
        data-tip="ver opciones"
        data-tip-position="right"
      >
        <span class="page" id="menu-switch" ref="trg_userMenu">
          <img :data-user="$store.getters.user.id" :src="$store.getters.user.avatar.small" />
        </span>
        <ul data-name="opciones" ref="userMenu">
          <li :class="{'is-profile' : $route.path == '/@'+$store.getters.user.username}">
            <router-link
              :to="`/@${$store.getters.user.username}`"
              @click.native="hideMobileSidebar"
            >
              <svgicon name="s_account"></svgicon>
              <p>ir a mi perfil</p>
            </router-link>
          </li>
          <li>
            <span @click="logout">
              <svgicon name="s_logout"></svgicon>
              <p>cerrar sesion</p>
            </span>
          </li>
        </ul>
      </li>
      <li
        :class="{'active' : $route.path == '/settings'}"
        data-tip="configuracion"
        data-tip-position="right"
      >
        <router-link to="/settings" class="page" @click.native="hideMobileSidebar">
          <svgicon name="n_settings"></svgicon>
        </router-link>
      </li>
    </ul>
  </nav>
</template>

<script>
import auth from "../api/auth";
import notifications from "../components/Notifications";
import { mapGetters, mapState } from "vuex";
import _ from "lodash";
import { get_ephemeris } from "@/lib/ephemeris";

import EventBus from "@/lib/event_bus";

export default {
  components: {
    name: "Navigation",
    notifications
  },
  data() {
    return {
      show_notif: false,
      show_userMenu: false,
      openSidebar: false
    };
  },
  computed: {
    ...mapGetters({
      newActivity: "newActivity"
    }),
    ...mapState(["show_navigation"]),
    ...mapGetters("notifications", ["unseen"]),
    ...mapGetters("chat", ["unread_conversations_count"]),
    are_unread_notifications() {
      return this.unread_conversations_count > 0;
    },
    n_notif: function() {
      if (this.unseen > 0) {
        return true;
      }
      return false;
    },
    isUser: function() {
      if (this.$store.getters.user.username == this.$route.params.name) {
        return true;
      }
      return false;
    },
    isNewActivity: function() {
      return this.newActivity > 0;
    },
    efemerides() {
      return get_ephemeris();
    },
    show() {
      return this.$mq != "sm" || this.show_navigation;
    }
  },
  methods: {
    logout() {
      auth.logout().then(() => window.location.reload(true));
    },
    switchSidebar() {
      if (this.openSidebar) {
        this.openSidebar = false;
        this.$root.$emit("closeSidebar");
      } else {
        this.openSidebar = true;
        this.$root.$emit("openSidebar");
      }
    },
    readMessages() {
      this.$store.dispatch("chat/updateUnreadMessagesCount", 0);
    },
    hideMobileSidebar() {
      if (this.$mq === "sm") {
        this.openSidebar = false;
        this.$root.$emit("closeSidebar");
      }
    }
  },
  mounted() {
    $(this.$refs.trg_notif).on({
      "click tap": () => {
        this.show_notif = true;
        this.$root.$emit("update-notifications-tab");
      }
    });

    $(window).on("click tap", e => {
      let isChild = !!$(e.target).parents("div#nav_dropdown").length;
      let isMenu = $(this.$refs.notif).is(e.target);
      let isTrigger = $(this.$refs.trg_notif).is(e.target.closest("a"));

      if (!isChild && !isMenu && !isTrigger) {
        // If click is issued outside notification menu and outside menu's trigger
        this.show_notif = false;
      }
    });

    $(this.$refs.trg_userMenu).on({
      "click tap": () => {
        this.show_userMenu = true;
      }
    });

    $(window).on("click tap", e => {
      let isChild = !!$(e.target).parents("span#menu-switch").length;
      let isMenu = $(this.$refs.userMenu).is(e.target);
      let isTrigger = $(this.$refs.trg_userMenu).is(e.target.closest("span"));

      if (!isChild && !isMenu && !isTrigger) {
        // If click is issued outside user menu and outside menu's trigger
        this.show_userMenu = false;
      }
    });

    EventBus.$on("toggle_navigation", value => {
      this.$store.dispatch("toggle_navigation", value);
    });
  }
};
</script>
