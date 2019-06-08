<template>
  <div class="media" @click="clicked">
    <div class="media-image" v-if="'image gif'.includes(media.type)">
      <img :src="media.url">
    </div>
    <div class="media-video" v-if="media.type == 'video'">
      <old-video v-if="media.legacy" :video="media"/>
      <video v-else controls :autoplay="autoplay" :poster="media.metadata.preview_url">
        <source :src="media.url" type="video/mp4">
      </video>
    </div>
  </div>
</template>

<script>
import OldVideo from "./OldVideo";

export default {
  name: "media-item",
  components: { OldVideo },
  props: {
    media: {
      type: Object,
      required: true
    },
    is_preview: {
      type: Boolean,
      default: false
    },
    autoplay: {
      type: Boolean,
      default: false
    }
  },
  methods: {
    clicked(ev) {
      this.$emit("clicked", ev);
    }
  }
};
</script>

<style lang="scss">
.media {
  width: 100%;

  *[class^="media-"] {
    width: 100%;

    & > video {
      width: 100%;
    }
  }
}
</style>
