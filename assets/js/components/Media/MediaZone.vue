<template>
  <div class="media-zone">
    <inline-medias v-if="$mq == 'sm'" :medias="medias"/>
    <template v-else>
      <single-media v-if="medias_length === 1" @clicked="clicked" :medias="medias"/>
      <two-medias v-if="medias_length === 2" @clicked="clicked" :medias="medias"/>
      <many-medias v-if="medias_length > 2" @clicked="clicked" :medias="medias"/>
    </template>
  </div>
</template>

<script>
import _ from "lodash";
import SingleMedia from "./layouts/SingleMedia";
import TwoMedias from "./layouts/TwoMedias";
import ManyMedias from "./layouts/ManyMedias";
import InlineMedias from "./layouts/InlineMedias";

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
  components: { SingleMedia, TwoMedias, ManyMedias, InlineMedias },
  computed: {
    medias_length() {
      return this.medias.length;
    }
  },
  methods: {
    clicked(id) {
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

  &.big {
    height: 340px;
  }
}
</style>

