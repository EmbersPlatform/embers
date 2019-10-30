<template>
  <div class="media-preview big" :class="{full_height: !overflowed}" @click="clicked">
    <div v-if="big" class="media-preview__image--big">
      <img v-if="media.type == 'image'" :src="preview_url" />
      <div v-if="overflowed" class="media-preview__overflowed-button">
        <span>Ampliar imagen</span>
      </div>
    </div>
    <div v-else class="media-preview__image" :style="{'background-image': `url(${preview_url})`}" />
    <div v-if="media.type == 'video'" class="media-preview__play-button">
      <i class="fas fa-play" />
    </div>
    <div v-if="media.type == 'gif'" class="media-preview__gif-button">
      <span>GIF</span>
    </div>
  </div>
</template>

<script>
const cloudinary_url =
  "https://res.cloudinary.com/embers-host/image/fetch/t_preview/";

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
    },
    high_res: {
      type: Boolean,
      default: false
    }
  },
  computed: {
    overflowed() {
      if (!this.$store.state.settings.settings.content_collapse_media)
        return false;
      if (this.media.metadata.height == "undefined") return false;
      return this.media.metadata.height > 500;
    },
    preview_url() {
      const url = this.high_res
        ? this.media.url
        : this.media.metadata.preview_url;
      if (/https?:\/\//.test(url)) {
        return cloudinary_url + url;
      } else {
        return url;
      }
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
  background-size: cover;
  background-position: center;
  flex-grow: 1;
  height: 160px;

  &.full_height {
    max-height: inherit !important;

    .media-preview__image--big {
      max-height: inherit !important;
    }
  }

  &.big {
    height: auto;
    max-width: 100%;
    max-height: 600px;
  }

  &:hover {
    box-shadow: 0 5px 5px #00000050;
    filter: brightness(80%);
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

.media-preview__gif-button {
  position: absolute;
  top: calc(50% - 1.5em);
  left: calc(50% - 1.5em);
  width: 3em;
  height: 3em;
  border-radius: 50%;
  background-color: #000000aa;
  border: 2px dotted #fff;
  color: #fff;
  line-height: 3em;
  text-align: center;
  font-size: 1.5em;
  span {
    font-weight: 500;
    font-size: 0.9em;
  }
}

.media-preview__image--big {
  width: 100%;
  max-height: 500px;
  text-align: center;
  overflow: hidden;
  img {
    border-radius: 10px;
  }
}
.media-preview__overflowed-button {
  position: absolute;
  bottom: 10px;
  left: 0;
  width: 100%;
  font-size: 3em;
  text-align: center;

  span {
    display: inline-block;
    color: #fffc;
    font-weight: 400;
    background: #000000cc;
    border-radius: 2em;
    padding: 5px 20px;
  }
}
</style>
