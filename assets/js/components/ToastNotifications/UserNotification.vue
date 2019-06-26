<template>
  <div class="toast-notif toast-notif--user">
    <avatar :avatar="data.image"/>
    <div class="notification-content">
      <router-link
        :to="`${link}#notif-id-${data.id}`"
        class="notification-title"
        @click.native="read"
        v-html="formatted_text"
      ></router-link>
    </div>
  </div>
</template>

<script>
import formatter from "@/lib/formatter.js";

import Avatar from "@/components/Avatar";

const make_link = function(notification) {};

export default {
  name: "UserNotification",
  components: { Avatar },
  props: {
    data: {
      type: Object,
      required: true
    }
  },
  computed: {
    formatted_text() {
      return formatter.format(this.data.text);
    },
    link() {
      const notification = this.data;
      switch (notification.type) {
        case "comment":
          return `/post/${notification.source_id}`;
          break;
        case "mention":
          return `/post/${notification.source_id}`;
          break;
        case "follow":
          return `/@${notification.from}`;
          break;
      }
    }
  },
  methods: {
    read() {
      this.$store.dispatch("notifications/read", this.data.id);
    }
  }
};
</script>

