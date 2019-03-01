<template>
  <div class="media-zone">
    <template v-if="medias.length < 3">
      <div class="row">
        <template v-if="previews">
          <div
            class="media-preview big"
            v-for="media in medias"
            :key="media.id"
            :style="{'background-image': `url(${media.metadata.preview_url})`}"
            @click="clicked(media.id)"
          ></div>
        </template>
        <template v-else>
          <media-item
            v-for="media in medias"
            :media="media"
            :key="media.id"
            @clicked="clicked(media.id)"
          ></media-item>
        </template>
      </div>
    </template>
    <template v-else>
      <template v-if="previews">
        <div
          class="media-preview big"
          :style="{'background-image': `url(${medias_head.metadata.preview_url})`}"
          @click="clicked(medias_head.id)"
        ></div>
      </template>
      <template v-else>
        <media-item :media="medias_head" @clicked="clicked(medias_head.id)"></media-item>
      </template>
      <div class="row">
        <template v-if="previews">
          <div
            class="media-preview"
            v-for="media in medias_tail"
            :key="media.id"
            :style="{'background-image': `url(${media.metadata.preview_url})`}"
            @click="clicked(media.id)"
          ></div>
        </template>
        <template v-else>
          <media-item
            v-for="media in medias_tail"
            :media="media"
            :key="media.id"
            @clicked="clicked(media.id)"
          ></media-item>
        </template>
      </div>
    </template>
  </div>
</template>

<script>
import _ from "lodash";
import MediaItem from "./MediaItem";

export default {
  name: "media-zone",
  props: {
    medias: {
      type: Array,
      required: true
    },
    previews: {
      type: Boolean,
      default: false
    }
  },
  components: { MediaItem },
  computed: {
    medias_head() {
      return _.head(this.medias);
    },
    medias_tail() {
      return _.tail(this.medias);
    }
  },
  methods: {
    clicked(id) {
      console.log("xd");
      this.$emit("clicked", id);
    }
  }
};
</script>

<style lang="scss">
.media-preview {
  position: relative;
  background-size: cover;
  background-position: center;
  flex-grow: 1;
  height: 160px;
  margin: 2px;
  border-radius: 2px;

  &.big {
    height: auto;
    padding-bottom: 70%;
  }
}
</style>

