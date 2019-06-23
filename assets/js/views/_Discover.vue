<template>
  <div id="board">
    <div id="heading">
      <Top></Top>
    </div>
    <div id="wrapper">
      <div id="content" data-layout-type="masonry">
        <div
          class="masonry"
          v-masonry
          transition-duration=".3s"
          item-selector=".item"
          fit-width="true"
        >
          <popular-tags class="item"/>
          <card
            class="item"
            v-for="post in posts"
            :key="post.id"
            :post="post"
            size="little"
            v-masonry-tile
          ></card>
        </div>
        <h3 v-if="loading_more">
          <p>Cargando mas...</p>
        </h3>
        <intersector @intersect="load_more"/>
      </div>
    </div>
  </div>
</template>

<script>
import axios from "axios";

import Card from "@/components/Card/_Card";
import Top from "@/components/Top";
import Intersector from "@/components/Intersector";
import PopularTags from "@/components/Tag/Popular";

export default {
  name: "Discover",
  components: {
    Top,
    Card,
    Intersector,
    PopularTags
  },
  data: () => ({
    loading_posts: false,
    loading_more: false,
    posts: [],
    next: null,
    last_page: false
  }),
  computed: {},
  methods: {
    async fetch_public() {
      this.loading_posts = true;
      const { data: res } = await axios.get(`/api/v1/feed/public`);
      this.posts = res.items;
      this.last_page = res.last_page;
      this.next = res.next;
      this.loading_posts = false;
    },
    async load_more() {
      if (this.loading_posts || this.loading_more || this.last_page) return;
      this.loading_more = true;
      const { data: res } = await axios.get(`/api/v1/feed/public`, {
        params: { before: this.next }
      });
      this.posts = res.items;
      this.last_page = res.last_page;
      this.next = res.next;
      this.loading_more = false;
    }
  },
  mounted() {
    this.fetch_public();
  },
  beforeDestroy() {
    this.$store.dispatch("cleanFeedPosts");
  }
};
</script>

<style lang="scss" scoped>
#content {
  justify-content: flex-start;
  align-items: center;
}
.hot-tags {
  width: 230px;
  margin: 0 15px 30px 15px;
}
</style>
