<template>
  <router-link :to="`/tag/${tag.name}`" class="tag" :class="{active: subbed}">
    <span>#{{tag.name}}</span>
  </router-link>
</template>

<script>
import { mapGetters } from "vuex";

import axios from "axios";

export default {
  name: "tag",
  props: {
    tag: {
      type: Object,
      required: true
    }
  },
  computed: {
    ...mapGetters("tag", ["tags"]),
    subbed() {
      const tag_names = this.tags.map(o => o.name);
      return tag_names.includes(this.tag.name);
    }
  }
};
</script>

<style lang="scss" scoped>
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

