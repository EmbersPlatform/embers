<template>
  <div class="hot-tags">
    <h3 v-if="tags.length">Tags populares</h3>
    <h4 v-if="loading_hot_tags">Cargando...</h4>
    <router-link :to="`/tag/${tag.name}`" v-for="tag in tags" :key="tag.tag.id">
      <p class="tag-name">
        #{{tag.tag.name}}
        <span>
          {{tag.count}}
          <template v-if="tag.count == 1">post</template>
          <template v-else>posts</template>
        </span>
      </p>
    </router-link>
  </div>
</template>

<script>
import axios from "axios";

export default {
  name: "PopularTags",
  data: () => ({
    tags: [],
    loading_hot_tags: false
  }),
  methods: {
    async get_hot_tags() {
      this.loading_hot_tags = true;
      const { data: res } = await axios.get(`/api/v1/tags/hot`);
      this.tags = res;
      this.loading_hot_tags = false;
    }
  },
  created() {
    this.get_hot_tags();
  }
};
</script>

<style lang="scss" scoped>
.hot-tags {
  h3 {
    font-weight: 400;
    font-size: 1.4em;
    padding-bottom: 10px;
  }
  a {
    display: block;
    color: #ffffffcc;
    padding: 5px 10px;
    transition: all 0.3s ease;
    font-size: 1.2em;

    &:not(:last-child) {
      border-bottom: 1px solid #ffffff10;
    }

    &:hover {
      background: #ffffff10;
      border-color: transparent;
    }

    span {
      display: inline-block;
      margin-left: 5px;
      border-radius: 2em;
      background: #ffffff10;
      padding: 0 5px;
      box-sizing: border-box;
    }
  }
}
</style>

