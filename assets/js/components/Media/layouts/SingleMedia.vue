<template>
  <div class="media-zone single-media">
    <media-item v-if="media.legacy" :media="media"/>
    <media-preview v-else :media="media" @clicked="clicked(media)" big/>
  </div>
</template>

<script>
import MediaItem from "../MediaItem";
import MediaPreview from "../MediaPreview";

export default {
  components: { MediaItem, MediaPreview },
  props: {
    medias: {
      type: Array,
      required: true
    }
  },
  computed: {
    media() {
      return this.medias[0];
    }
  },
  methods: {
    clicked(media) {
      this.$emit("clicked", media.id);
    }
  }
};
</script>

<style lang="scss">
.media-zone.single-media {
  .media-preview {
    width: 100%;
  }
}
</style>
