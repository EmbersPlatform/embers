<template>
  <div class="media-zone" :class="{small: small}">
    <small-medias v-if="small" :medias="medias" @clicked="clicked"/>
    <template v-else>
      <inline-medias v-if="$mq == 'sm' && !small" :medias="medias" @clicked="clicked"/>
      <template v-else>
        <single-media v-if="medias_length === 1" @clicked="clicked" :medias="medias"/>
        <two-medias v-if="medias_length === 2" @clicked="clicked" :medias="medias"/>
        <many-medias v-if="medias_length > 2" @clicked="clicked" :medias="medias" :little="little"/>
      </template>
    </template>
  </div>
</template>

<script>
import _ from "lodash";
import SingleMedia from "./layouts/SingleMedia";
import TwoMedias from "./layouts/TwoMedias";
import ManyMedias from "./layouts/ManyMedias";
import InlineMedias from "./layouts/InlineMedias";
import SmallMedias from "./layouts/SmallMedias";
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
    },
    small: {
      type: Boolean,
      default: false
    },
    little: {
      type: Boolean,
      default: false
    }
  },
  components: { SingleMedia, TwoMedias, ManyMedias, InlineMedias, SmallMedias },
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
.media-zone {
  border-radius: 10px;
  overflow: hidden;
}
</style>

