<template>
  <div class="media-zone many-medias">
    <media-preview :media="first_media" @clicked="clicked(first_media)"/>
    <div class="row">
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

export default {
  components: { MediaPreview },
  props: {
    medias: {
      type: Array,
      required: true
    }
  },
  computed: {
    first_media() {
      return this.medias[0];
    },
    remaining() {
      return this.medias.slice(1);
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
    height: 300px;
    margin-bottom: 5px;
  }
  .row {
    display: flex;
    flex-direction: row;
    .media-preview {
      flex-grow: 1;
      width: auto;
      height: 160px;
      justify-content: space-between;
      &:nth-child(2) {
        margin: 0 5px;
      }
    }
  }
}
</style>
