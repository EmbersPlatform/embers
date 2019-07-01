<template>
  <div class="media-zone many-medias">
    <media-preview
      v-if="little"
      :media="first_media"
      @clicked="clicked(first_media)"
      class="media-zone__first-media"
    />
    <media-preview v-else :media="first_media" @clicked="clicked(first_media)" />

    <div class="row" ref="minis">
      <media-preview
        v-for="media in remaining"
        :key="media.id"
        :media="media"
        @clicked="clicked(media)"
      />
    </div>
  </div>
</template>

<script>
import MediaPreview from "../MediaPreview";
import MediaItem from "../MediaItem";

export default {
  components: { MediaPreview, MediaItem },
  props: {
    medias: {
      type: Array,
      required: true
    },
    little: {
      type: Boolean,
      default: false
    }
  },
  computed: {
    first_media() {
      return this.medias[0];
    },
    remaining() {
      return this.medias.slice(1);
    },
    preview_height() {
      if (this.little) {
        const media = this.medias[0];
        const vh = Math.max(
          document.documentElement.clientHeight,
          window.innerHeight || 0
        );
        if (media.metadata.height > 0.25 * vh) return "25vh";
        return media.metadata.height + "px";
      }
      const media = this.medias[0];
      const vw = Math.max(
        document.documentElement.clientWidth,
        window.innerWidth || 0
      );
      if (media.metadata.height > 0.75 * vw) return "75vh";
      return media.metadata.height + "px";
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
.media-zone.many-medias {
  display: flex;
  flex-direction: row;
  & > .media-preview {
    flex-grow: 1;
    border-right: 2px solid transparent;
    height: auto;
    .media-preview__image {
      padding-top: 100%;
      height: fit-content;
    }
  }
  .row {
    flex-basis: 33%;
    flex-shrink: 0;
    display: flex;
    flex-direction: column;
    .media-preview {
      flex-grow: 1;
      width: auto;
      height: fit-content;
      justify-content: space-between;
      &:not(:first-child) {
        border-top: 2px solid transparent;
      }
    }
  }
  .media-zone__first-media {
    height: auto;
    .media-preview__image {
      padding-top: 100%;
      height: fit-content;
    }
  }
}
</style>
