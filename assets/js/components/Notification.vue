<template>
  <li :class="{ unread: !read }">
    <router-link :to="url" @click.native="mark_as_read">
      <avatar v-if="notification.from" :avatar="notification.image"/>
      <span v-else v-text="notification.type"></span>
      <div class="tip">
        <p v-html="formatted_text"></p>
        <span>{{$moment.utc(notification.inserted_at).local().from()}}</span>
      </div>
    </router-link>
  </li>
</template>

<script>
import formatter from "@/lib/formatter";

import Avatar from "@/components/Avatar";

import axios from "axios";

export default {
  props: {
    notification: {
      type: Object,
      required: true
    }
  },
  components: { Avatar },
  computed: {
    seen() {
      return this.notification.status == 1;
    },
    read() {
      return this.notification.status == 2;
    },
    formatted_text() {
      return formatter.format(this.notification.text);
    },
    url() {
      const notif = this.notification;
      switch (notif.type) {
        case "comment":
          return `/@${notif.from}/${notif.source_id}`;
        case "mention":
          return `/@${notif.from}/${notif.source_id}`;
        case "follow":
          return `/@${notif.from}`;
        case true:
          return null;
      }
    }
  },
  methods: {
    async mark_as_read() {
      await axios.put(`/api/v1/notifications/${this.notification.id}`);
      this.$store.dispatch("notifications/read", this.notification.id);
    }
  }
};
</script>
