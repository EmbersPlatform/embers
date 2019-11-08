<template>
  <div class="media" @click="clicked">
    <div class="media-image" v-if="'image gif'.includes(media.type)">
      <img :src="preview_url" />
    </div>
    <div class="media-video" v-if="media.type == 'video'">
      <old-video v-if="media.legacy" :video="media" />
      <video v-else controls :autoplay="autoplay" :poster="media.metadata.preview_url">
        <source :src="media.url" type="video/mp4" />
      </video>
    </div>
  </div>
</template>

<script>
import OldVideo from "./OldVideo";
const cloudinary_url =
  "https://res.cloudinary.com/embers-host/image/fetch/t_optimize/";

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
  },
  computed: {
    preview_url() {
      if (this.media.from_link) return this.media.url;
      const url = this.media.url;
      if (/https?:\/\//.test(url)) {
        return cloudinary_url + url;
      } else {
        return url;
      }
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
