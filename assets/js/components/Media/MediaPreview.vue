<template>
  <div class="media-preview" @click="clicked">
    <div
      class="media-preview__image"
      :style="{'background-image': `url(${media.metadata.preview_url})`}"
    />
    <div v-if="media.type == 'video'" class="media-preview__play-button">
      <font-awesome-icon :icon="['fas', 'play']"/>
    </div>
  </div>
</template>

<script>
export default {
  name: "MediaPreview",
  props: {
    media: {
      type: Object,
      required: true
    }
  },
  methods: {
    clicked() {
      this.$emit("clicked", this.media);
    }
  }
};
</script>

<style lang="scss">
@import "~@/../sass/base/_variables.scss";

.media-preview {
  width: 100px;
  height: 100px;
  cursor: pointer;
  position: relative;
  transition: all 0.3s ease;
  transform: scale(1);

  &:hover {
    box-shadow: 0 5px 5px #00000050;
    transform: scale(1.005);
  }

  .media-preview__image {
    width: 100%;
    height: 100%;
    background-size: cover;
    background-position: top center;
  }
  .media-preview__play-button {
    position: absolute;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    border: 5px solid #fff;
    background: $narrojo;
    color: #fff;
    box-sizing: border-box;
    border-radius: 50%;
    text-align: center;
    padding: 20px;

    svg {
      font-size: 1.5rem;
    }
  }
}
</style>
