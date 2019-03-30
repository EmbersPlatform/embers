<template>
  <li :class="status">
    <router-link :to="link" @click.native="read">
      <Avatar :avatar="image"/>
      <div class="tip">
        <p v-html="formatted_text"/>
        <span v-text="time"/>
      </div>
    </router-link>
  </li>
</template>

<script>
import formatter from "@/lib/formatter.js";

import Avatar from "@/components/Avatar";
import axios from "axios";

const make_link = function(notification) {
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
};

export default {
  name: "Notification",
  components: { Avatar },
  props: {
    notification: {
      type: Object,
      required: true
    }
  },
  computed: {
    formatted_text() {
      return formatter.format(this.notification.text);
    },
    time() {
      return this.$moment
        .utc(this.notification.inserted_at)
        .local()
        .from();
    },
    link() {
      return make_link(this.notification);
    },
    image() {
      return this.notification.image;
    },
    status() {
      switch (this.notification.status) {
        case 0:
          return "unseen";
          break;
        case 1:
          return "unread";
          break;
        case 2:
          return "read";
          break;
      }
    }
  },
  methods: {
    read() {
      this.$store.dispatch("notifications/read", this.notification.id);
    }
  }
};
</script>

