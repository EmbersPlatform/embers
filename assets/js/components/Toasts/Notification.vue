<template>
  <a
    slot="body"
    slot-scope="props"
    class="notification"
    :class="type"
    @click="handle_click"
    rel="root"
    :href="link"
  >
    <avatar v-if="hasImage" :avatar="props.item.data.image"/>
    <div class="notification-content">
      <span class="notification-text" v-html="formatted_text"></span>
    </div>
    <button class="notification-close" @click.stop="props.close">x</button>
  </a>
</template>

<script>
import avatar from "@/components/Avatar";
import formatter from "@/lib/formatter";

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
  name: "ToastNotification",
  props: ["props"],
  components: { avatar },
  data() {
    return {
      type: this.props.item.type
    };
  },
  computed: {
    hasImage() {
      return this.props.item.data && "image" in this.props.item.data;
    },
    formatted_text() {
      return formatter.format(this.props.item.text);
    },
    link() {
      const notification = this.props.item.data.notification;
      if (!notification) {
        if (!this.props.item.data.link) return false;
        return this.props.item.data.link;
      } else {
        return make_link(notification);
      }
    }
  },
  methods: {
    close() {
      if (
        this.props.item.data &&
        typeof this.props.item.data.close === "function"
      )
        return this.props.item.data.close();
    },
    handle_click() {
      this.props.close();
      this.close();
      if (this.props.item.data.realtime) {
        this.$store.dispatch(
          "notifications/read",
          this.props.item.data.notification.id
        );
      }
    }
  }
};
</script>
