<template>
  <div class="media-zone" :class="{small: small}">
    <small-medias v-if="small" :medias="ordered_medias" @clicked="clicked"/>
    <template v-else>
      <inline-medias v-if="$mq == 'sm' && !small" :medias="ordered_medias" @clicked="clicked"/>
      <template v-else>
        <single-media v-if="medias_length === 1" @clicked="clicked" :medias="ordered_medias"/>
        <two-medias v-if="medias_length === 2" @clicked="clicked" :medias="ordered_medias"/>
        <many-medias
          v-if="medias_length > 2"
          @clicked="clicked"
          :medias="ordered_medias"
          :little="little"
        />
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
    },
    ordered_medias() {
      const ordered = _.orderBy(this.medias, "timestamp", "asc");
      console.log(ordered);
      return ordered;
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

