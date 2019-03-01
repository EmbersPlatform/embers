<template>
  <popper trigger="hover" :options="{placement: 'top'}">
    <div class="popper tag-popup">
      <div class="tag-top">
        <div class="tag-name" v-text="tag.name"></div>
        <button
          @click="sub_tag"
          data-button-size="small"
          data-button-font="small"
          class="button"
          v-text="sub_text"
          :data-button-important="!subbed"
        ></button>
      </div>
      <div class="tag-description">Aca va la descripcion del tag(si la tiene)</div>
    </div>
    <router-link slot="reference" :to="`/search/in:${tag}`" class="tag" :class="{active: subbed}">
      <span>#{{tag.name}}</span>
    </router-link>
  </popper>
</template>

<script>
import Popper from "vue-popperjs";
import "vue-popperjs/dist/vue-popper.css";
import { mapGetters } from "vuex";

import axios from "axios";

export default {
  name: "tag",
  data() {
    return {
      subbed: false
    };
  },
  props: {
    tag: {
      type: Object,
      required: true
    }
  },
  components: { Popper },
  computed: {
    ...mapGetters("tag", ["tags"]),
    sub_text() {
      return this.subbed ? "desuscribirme" : "suscribirme";
    }
  },
  methods: {
    async sub_tag() {
      try {
        if (!this.subbed) {
          let tag = (await axios.post(`/api/v1/subscriptions/tags`, {
            id: this.tag.id
          })).data;
          this.subbed = true;
          this.$store.dispatch("tag/add", tag);
        } else {
          await axios.delete(`/api/v1/subscriptions/tags/${this.tag.id}`);
          this.subbed = false;
          this.$store.dispatch("tag/delete", this.tag.name);
        }
      } catch (e) {
        this.$notify({
          group: "top",
          text: "Hubo un problema al suscribirse al tag.",
          type: "error"
        });
      }
    }
  },
  created() {
    let tag_names = this.tags.map(o => o.name);
    this.subbed = tag_names.includes(this.tag.name);
  }
};
</script>

<style lang="scss">
@import "~@/../sass/base/_variables.scss";
@import "~@/../sass/base/_mixins.scss";

.tag {
  @include font-size();
  padding: 2px 10px;
  border: 2px solid transparent;
  border-radius: 2em;
  margin: 0;

  transition: 100ms ease all;

  &:not(:last-child) {
    margin-right: 5px;
  }

  &:hover {
    background-color: #ffffff16;
    border-color: #ffffff11;
    box-shadow: 0 2px 13px -1px #00000091;
  }

  &.active {
    background-color: $narrojo;
    border-color: #ffffff22;
    color: #ffffff99;
    font-weight: bold;
    opacity: 0.7;

    &:hover {
      opacity: 1;
    }
  }
}

.tag-popup {
  background: $dark;
  color: #ddd;
  box-shadow: rgba(0, 0, 0, 0.17) 0 0 6px 0;
  border-color: darken($dark, 2);
  min-width: 200px;
  text-align: left;
  padding: 5px 10px;

  .tag-top {
    padding-bottom: 5px;
    display: flex;
    flex-direction: row;
    justify-content: space-between;

    .tag-name {
      font-weight: bold;
      font-size: 1.1em;
    }
  }
  .tag-description {
    padding-bottom: 5px;
  }

  &[x-placement^="top"] {
    .popper__arrow {
      border-color: $dark transparent transparent transparent;
    }
  }
  &[x-placement^="right"] {
    .popper__arrow {
      border-color: transparent $dark transparent transparent;
    }
  }
  &[x-placement^="bottom"] {
    .popper__arrow {
      border-color: transparent transparent $dark transparent;
    }
  }
  &[x-placement^="left"] {
    .popper__arrow {
      border-color: transparent transparent transparent $dark;
    }
  }
}
</style>

