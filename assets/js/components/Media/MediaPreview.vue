<template>
  <div class="media-preview big" @click="clicked">
    <div v-if="big" class="media-preview__image--big">
      <img v-if="media.type == 'image'" :src="media.url">
      <img v-else :src="media.metadata.preview_url">
      <div v-if="overflowed" class="media-preview__overflowed-button">
        <i class="fas fa-caret-down"/>
      </div>
    </div>
    <div
      v-else
      class="media-preview__image"
      :style="{'background-image': `url(${media.metadata.preview_url})`}"
    />
    <div v-if="media.type == 'video'" class="media-preview__play-button">
      <i class="fas fa-play"/>
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
    },
    big: {
      type: Boolean,
      default: false
    }
  },
  computed: {
    overflowed() {
      if (this.media.metadata.height == "undefined") return false;
      return this.media.metadata.height > 500;
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
  background-size: cover;
  background-position: center;
  flex-grow: 1;
  height: 160px;

  &.big {
    height: auto;
    max-width: 100%;
    max-height: 600px;
  }

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
.media-preview__image--big {
  width: 100%;
  max-height: 500px;
  text-align: center;
  overflow: hidden;
}
.media-preview__overflowed-button {
  position: absolute;
  bottom: 0;
  left: 0;
  width: 100%;
  font-size: 3em;
  text-align: center;
  color: #fff;
  text-shadow: 0 0 2px black;
  background: linear-gradient(transparent, #000000cc);
}
</style>
