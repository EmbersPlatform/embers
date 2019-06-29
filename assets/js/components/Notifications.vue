<template>
  <ul :class="{renderbox : loading}">
    <template v-if="!loading">
      <Notification
        v-for="notification in notifications"
        :key="notification.id"
        :notification="notification"
      />
      <intersector @intersect="load_more" />
      <center v-if="loading_more">Cargando notificaciones...</center>
    </template>
  </ul>
</template>

<script>
import notification from "../api/notification";
import Notification from "@/components/Notification";
import Intersector from "@/components/Intersector";

import { mapGetters } from "vuex";
import avatar from "@/components/Avatar";

export default {
  components: {
    avatar,
    Notification,
    Intersector
  },
  computed: {
    ...mapGetters({ notifications: "notifications" })
  },
  methods: {
    async loadNotifications() {
      this.loading = true;
      const res = await notification.get(null, true);
      this.$store.dispatch("notifications/update", res.items);
      this.last_page = res.last_page;
      this.next = res.next;
      this.loading = false;
    },
    async load_more() {
      if (this.loading || this.loading_more || this.last_page) return;
      this.loading_more = true;
      const res = await notification.get(this.next, false);
      this.$store.dispatch("notifications/append", res.items);
      this.last_page = res.last_page;
      this.next = res.next;
      this.loading_more = false;
    }
  },
  data: () => ({
    loading: false,
    loading_more: false,
    next: null,
    last_page: false
  }),
  async mounted() {
    this.loading = true;
    const res = await notification.get(null, true);
    this.last_page = res.last_page;
    this.next = res.next;
    this.$store.dispatch("notifications/mark_as_seen");
    this.loading = false;
  }
};
</script>
