<template>
  <div
    class="media-slide"
    v-shortkey="['esc']"
    @shortkey="close"
    @click.stop="click_outside"
    ref="root"
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
        class="slides-control"
      >
        <i class="fa fa-chevron-left"></i>
      </button>
      <media-item
        v-for="(media, m_index) in ordered_medias"
        :key="m_index"
        :media="media"
        v-show="m_index == index"
        :autoplay="true"
      ></media-item>
      <button
        @click="next"
        v-visible="medias_count - 1 != index"
        v-shortkey="['arrowright']"
        @shortkey="next"
        class="slides-control"
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
  }
};
</script>

<style lang="scss">
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
    height: 95%;
    // background: #333;
    display: flex;
    flex-direction: row;
    align-items: center;

    .slides-control,
    .close-slides {
      text-shadow: 0 0 5px #000;
    }

    .slides-control {
      height: 100%;
      flex: 1 1 auto;
      width: 10%;
      background-color: transparent;
      color: #fff;
      font-size: 3em;
      cursor: pointer;
    }

    .close-slides {
      position: absolute;
      top: 0;
      right: 0;
      z-index: 1;
      font-size: 2.5em;
      box-sizing: border-box;
      display: block;
      width: 1.5em;
      height: 1.5em;
      line-height: 1.5em;
      text-align: center;
      color: #fff;
      background-color: transparent;
    }

    .media {
      width: 100%;
      height: 100%;
      display: flex;
      justify-content: center;
      align-items: center;
      overflow-y: auto;
    }
    *[class^="media-"] {
      max-width: 100%;
      max-height: 100%;
      width: auto;
      display: inline-block;
      box-shadow: 0 2px 8px 3px #000000a3;
      background-color: #1a1b1d;

      img {
        max-width: 100%;
        max-height: 100%;
        width: auto;
      }
    }
  }
}
</style>
