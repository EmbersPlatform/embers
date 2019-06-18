<template>
  <div class="toast-notif toast-notif--reaction">
    <avatar :avatar="data.avatar"></avatar>
    <div class="reaction-icon">
      <img :src="`/img/emoji/${data.reaction}.svg`">
    </div>
    <div class="notification-content">
      <a :href="`/post/${data.post_id}`" taget="_blank" class="notification-title" v-html="text"></a>
    </div>
  </div>
</template>

<script>
import formatter from "@/lib/formatter";
import avatar from "@/components/Avatar";

export default {
  name: "ToastNotification",
  props: {
    data: {
      type: Object,
      required: true
    }
  },
  components: { avatar },
  computed: {
    text() {
      switch (this.data.type) {
        case "post_reaction":
          return formatter.format(
            `**@${this.data.from}** reaccionó a tu **post**`
          );
          break;
        case "comment_reaction":
          return formatter.format(
            `**@${this.data.from}** reaccionó a tu **comentario**`
          );
          break;
      }
    }
  }
};
</script>

<style lang="scss" scoped>
.avatar {
  width: 32px;
  height: 32px;
}
.reaction-icon {
  position: absolute;
  left: 25px;
  bottom: 0;
  width: 30px;
  height: 30px;
  display: block;
  box-sizing: border-box;
  padding: 3px;
  border-radius: 50%;
  background: #1b1c1f;
  overflow: hidden;
  img {
    width: 100%;
    height: 100%;
    display: block;
    padding: 3px;
    box-sizing: border-box;
  }
}
</style>

