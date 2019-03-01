<template>
  <ul :class="{renderbox : loading}">
    <template v-if="!loading">
      <notification
        v-for="notification in notifications"
        :key="notification.id"
        :notification="notification"
      />
      <li class="notifications-empty" v-if="notifications.length === 0">
        <div class="tip">
          <p>Y en el inicio... había silencio.</p>
        </div>
      </li>
    </template>
  </ul>
</template>

<script>
import notification from "../api/notification";
import Notification from "./Notification";

import { mapGetters } from "vuex";
import avatar from "@/components/Avatar";
import formatter from "@/lib/formatter";
import axios from "axios";

export default {
  components: {
    avatar,
    Notification
  },
  computed: {
    ...mapGetters("notifications", ["notifications"])
  },
  methods: {
    async load_notifications() {
      this.loading = true;
      let notifications = (await axios.get(
        `/api/v1/notifications?set_status=1`
      )).data;
      this.$store.dispatch("notifications/update", notifications.items);
      this.loading = false;
    },
    format_text(text) {
      return formatter.format(text);
    }
  },

  /**
   * Component data
   * @returns object
   */
  data() {
    return {
      loading: false
    };
  },

  /**
   * Triggered when an instance of this component is created
   */
  created() {
    this.load_notifications();
    // this.$root.$on("update-notifications-tab", () => this.loadNotifications());
  }
};
</script>
