<template>
  <div class="tag-options">
    <button
      class="button"
      data-button-size="medium"
      data-button-text="medium"
      :data-button-important="!is_pinned"
      @click="handle_pin"
    >{{ pin_text }}</button>
    <button
      v-if="is_pinned"
      class="button"
      data-button-size="medium"
      data-button-text="medium"
      :data-button-important="!is_subbed"
      :data-tip="bell_tip"
      data-tip-position="top"
      data-tip-text
      @click="handle_sub"
    >
      <i :class="bell_icon"></i>
    </button>
  </div>
</template>


<script>
import axios from "axios";

export default {
  name: "TagOptions",
  props: {
    tag: {
      type: Object,
      required: true
    }
  },
  data: () => ({
    show_options: false
  }),
  computed: {
    bell_icon() {
      if (this.is_subbed) {
        return "fas fa-bell";
      } else {
        return "far fa-bell";
      }
    },
    bell_tip() {
      if (this.is_subbed) {
        return "Dejar de recibir posts con este tag en el Inicio";
      } else {
        return "Recibir posts con este tag en el Inicio";
      }
    },
    pin_text() {
      if (this.is_pinned) {
        return "Quitar pin";
      } else {
        return "Pinear";
      }
    },
    is_pinned() {
      return this.tag.sub_level != null && this.tag.sub_level >= 0;
    },
    is_subbed() {
      return this.tag.sub_level == 1;
    }
  },
  methods: {
    set_level(level) {},
    handle_pin() {
      if (this.is_pinned) {
        this.unpin();
      } else {
        this.pin();
      }
    },
    handle_sub() {
      if (this.is_subbed) {
        this.set_level(0);
      } else {
        this.set_level(1);
      }
    },
    async set_level(level) {
      await axios.post(`/api/v1/subscriptions/tags/`, {
        id: this.tag.id,
        level: level
      });
      this.tag.sub_level = level;
    },
    async pin() {
      await axios.post(`/api/v1/subscriptions/tags`, {
        id: this.tag.id,
        level: 0
      });
      this.$store.dispatch("tag/add", this.tag);
      this.tag.sub_level = 0;
    },
    async unpin() {
      await axios.delete(`/api/v1/subscriptions/tags/${this.tag.id}`);
      this.$store.dispatch("tag/delete", this.tag.name);
      this.tag.sub_level = null;
    }
  }
};
</script>

<style lang="scss" scoped>
.tag-options {
  display: flex;
}
</style>
