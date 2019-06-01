<template>
  <div class="media-zone many-medias">
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
@import "~@/../sass/base/_variables.scss";

.media-zone.many-medias {
  display: flex;
  flex-direction: row;
  .media-preview {
    flex-grow: 0;
    width: 100px;
    height: 100px;
    margin: 0 5px;
    border-radius: 5px;
    overflow: hidden;
  }
  @media #{$query-mobile} {
    .media-preview {
      width: 25%;
      margin: 5px 0;
      box-sizing: border-box;
      border: 2px solid transparent;
    }
  }
}
</style>
