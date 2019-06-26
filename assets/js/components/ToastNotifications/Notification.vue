<template>
  <div
    slot="body"
    slot-scope="props"
    class="notification"
    :class="type"
    @click="props.close(); close();"
    rel="root"
  >
    <component v-if="component" :is="component" :data="props.item.data"></component>
    <div class="notification-content" v-else>
      <span class="notification-text" v-html="props.item.text"></span>
    </div>
    <button class="notification-close" @click.stop="props.close">x</button>
  </div>
</template>

<script>
import Reaction from "./ReactionNotification";
import User from "./UserNotification";

export default {
  name: "ToastNotification",
  props: ["props"],
  computed: {
    component() {
      if (!this.props.item.data) return null;
      switch (this.props.item.data.type) {
        case "post_reaction":
        case "comment_reaction":
          return Reaction;
          break;
        case "comment":
        case "mention":
        case "follow":
          return User;
          break;
      }
    },
    type() {
      return this.props.item.type;
    }
  },
  methods: {
    close() {
      if (
        this.props.item.data &&
        typeof this.props.item.data.close === "function"
      )
        return this.props.item.data.close();
    }
  }
};
</script>

<style lang="scss">
.toast-notif {
  display: flex;
  flex-direction: row;
  align-items: center;
  .notification-content {
    flex: 1 auto;
    a {
      color: #ffffffcc;
    }
  }
}
</style>
