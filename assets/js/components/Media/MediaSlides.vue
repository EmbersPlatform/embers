<template>
  <div
    class="media-slide"
    ref="root"
    v-shortkey="['esc']"
    @shortkey="close"
    @click.stop="click_outside"
  >
    <div class="media-slide-content">
      <button class="close-slides" @click="close">
        <i class="fa fa-times"></i>
      </button>
      <button
        @click="previous"
        v-visible="index > 0"
        v-shortkey="['arrowleft']"
        @shortkey="previous"
        class="slides-control slides-control--prev"
      >
        <i class="fa fa-chevron-left"></i>
      </button>
      <template v-for="(media, m_index) in ordered_medias">
        <media-item
          :key="m_index"
          :media="media"
          v-if="m_index == index"
          :autoplay="true"
        ></media-item>
      </template>
      <button
        @click="next"
        v-visible="medias_count - 1 != index"
        v-shortkey="['arrowright']"
        @shortkey="next"
        class="slides-control slides-control--next"
      >
        <i class="fa fa-chevron-right"></i>
      </button>
    </div>
  </div>
</template>

<script>
import _ from "lodash";
import { mapState } from "vuex";
import MediaItem from "./MediaItem";

export default {
  name: "media-slides",
  components: {
    MediaItem
  },
  computed: {
    ...mapState("media_slides", ["medias", "index"]),
    medias_count() {
      return this.medias.length;
    },
    current_media() {
      return this.ordered_medias[this.current_index];
    },
    ordered_medias() {
      const ordered = _.orderBy(this.medias, "timestamp", "asc");
      return ordered;
    }
  },
  methods: {
    previous() {
      if (this.index == 0) return;
      this.$store.dispatch("media_slides/set_index", this.index - 1);
    },
    next() {
      if (this.index >= this.medias.length - 1) return;
      this.$store.dispatch("media_slides/set_index", this.index + 1);
    },
    close() {
      this.$store.dispatch("media_slides/close");
    },
    click_outside(e) {
      if (e.target == this.$refs.root) this.close();
    }
  },
  mounted() {
    document.documentElement.classList.add("scroll-lock")
  },
  beforeDestroy() {
    document.documentElement.classList.remove("scroll-lock")
  }
};
</script>

<style lang="scss">
@import "~@/../sass/base/_variables.scss";

.media-slide {
  position: fixed;
  top: 0;
  left: 0;
  width: 100vw;
  height: 100vh;
  z-index: 100;
  box-sizing: border-box;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  background-color: #0000009e;

  .media-slide-content {
    width: 80%;
    height: 90%;
    background: #333;
    display: flex;
    flex-direction: row;
    align-items: center;
    overflow-y: hidden;
    border-radius: 10px;

    @media #{$query-mobile} {
      width: 100%;
      height: 100%;
    }

    .slides-control,
    .close-slides {
      cursor: pointer;
      display: block;
      height: 2em;
      width: 2em;
      font-size: 1.2em;
      background: #0008;
      border-radius: 50%;
    }

    .slides-control {
      flex: 1 1 auto;
      color: #fff;
      cursor: pointer;
      position: absolute;
      z-index: 1;

      &.slides-control--prev {
        left: 10px;
      }
      &.slides-control--next {
        right: 10px;
      }
    }

    .close-slides {
      position: absolute;
      top: 10px;
      right: 10px;
      z-index: 1;
      box-sizing: border-box;
      display: block;
      text-align: center;
      color: #fff;
    }

    .media {
      width: 100%;
      height: 100%;
      display: flex;
      justify-content: center;
      align-items: center;
      margin: auto auto;
    }
    *[class^="media-"] {
      width: 100%;
      height: 100%;
      width: auto;
      display: flex;
      background-color: #1a1b1d;
      align-items: center;

      img {
        max-width: 100%;
        max-height: 100%;
        width: auto;
      }
    }
  }
}
</style>
