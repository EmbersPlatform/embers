<template>
<div id="wrapper" data-layout-type="column">
  <div class="block" data-layout-type="column">
    <h2>Mis Tags</h2>
  </div>
  <div class="block" data-layout-type="wide" :class="{'renderbox': loadingTags}" :data-renderbox-message="'Cargando...'">
    <span class="tag" v-for="tag in tags">{{tag.name}}</span>
  </div>
</div>
</template>

<script>

import tagAPI from '../../api/tag';

export default {
  name: 'Tags',

  data() {
    return {
      loadingTags: false,
      loadingBlockedTags: false,
      tags: null,
      blockedTags: null,
    }
  },

  methods: {
    fetchTags() {
      this.loadingTags = true;
      tagAPI.getTags().then(res => {
        this.tags = res;
      }).finally(() => {
        this.loadingTags = false;
      });
    },
    fetchBlockedTags() {
      this.loadingBlockedTags = true;
      tagAPI.getBlockedTags().then(res => {
        this.blockedTags = res;
      }).finally(() => {
        this.loadingBlockedTags = false;
      });
    }
  },

  mounted() {
    this.fetchTags();
    this.fetchBlockedTags();
  }
}
</script>