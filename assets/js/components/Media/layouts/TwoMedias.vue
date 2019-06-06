<template>
  <div class="media-zone two-medias">
    <media-preview
      v-for="media in medias"
      :key="media.id"
      :media="media"
      @clicked="clicked(media)"
    />
  </div>
</template>

<script>
import MediaPreview from "../MediaPreview";

export default {
  components: { MediaPreview },
  props: {
    medias: {
      type: Array,
      required: true
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
.media-zone.two-medias {
  display: flex;
  flex-direction: row;
  .media-preview {
    width: 50%;
    &:last-child {
      margin-left: 5px;
    }
    .media-preview__image {
      padding-top: 100%;
    }
  }
}
</style>
