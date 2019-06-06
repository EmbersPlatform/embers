<template>
  <div class="media-zone many-medias">
    <media-item
      v-if="first_media.type == 'image'"
      :media="first_media"
      :style="`max-height: ${preview_height};`"
      @clicked="clicked(first_media)"
    />
    <media-preview
      v-else
      :media="first_media"
      @clicked="clicked(first_media)"
      :style="`height: ${preview_height};`"
    />
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
  & > .media-preview {
    width: 100%;
    height: 75vw;
    margin-bottom: 5px;
  }
  & > .media {
    justify-content: flex-start;
    margin-bottom: 5px;
    overflow: hidden;
    img {
      width: 100%;
    }
  }
  .row {
    display: flex;
    flex-direction: row;
    .media-preview {
      flex-grow: 1;
      width: auto;
      height: fit-content;
      justify-content: space-between;
      &:not(:last-child) {
        margin-right: 5px;
      }
      .media-preview__image {
        padding-top: 100%;
      }
    }
  }
}
</style>
