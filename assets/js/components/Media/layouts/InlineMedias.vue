<template>
  <div class="media-zone inline-medias" :scrollable="$mq == 'sm'">
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
  computed: {},
  methods: {
    clicked(media) {
      this.$emit("clicked", media.id);
    }
  }
};
</script>

<style lang="scss">
.media-zone.inline-medias {
  display: flex;
  flex-direction: column;
  align-items: center;
  .media-preview {
    width: 80%;
    height: 300px;
  }

  &[scrollable] {
    flex-direction: row;
    overflow-x: auto;

    .media-preview {
      width: 85vw;
      height: 75vh;
      flex-shrink: 0;
      margin-right: 5px;
    }
  }
}
</style>
