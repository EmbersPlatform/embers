<template>
  <ul :class="{renderbox : loading}">
    <template v-if="!loading">
      <Notification
        v-for="notification in notifications"
        :key="notification.id"
        :notification="notification"
      />
    </template>
  </ul>
</template>

<script>
import notification from "../api/notification";
import Notification from "@/components/Notification";

import { mapGetters } from "vuex";
import avatar from "@/components/Avatar";

export default {
  components: {
    avatar,
    Notification
  },
  computed: {
    ...mapGetters({ notifications: "notifications" })
  },
  methods: {
    loadNotifications() {
      this.loading = true;
      notification
        .get(
          this.notifications.length
            ? this.notifications[this.notifications.length - 1].id
            : null,
          true
        )
        .then(res => {
          this.$store.dispatch("notifications/update", res.items);
        })
        .finally(() => (this.loading = false));
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
    notification.get(null, true); // Mark as seen
    this.$store.dispatch("notifications/mark_as_seen");
  }
};
</script>
