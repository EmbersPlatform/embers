<template>
  <div id="board">
    <div id="heading">
      <Top></Top>
    </div>
    <div id="wrapper">
      <div id="content" data-layout-type="masonry">
        <h3 v-if="loading_tag">
          <p>Cargando tag...</p>
        </h3>
        <div class="tag-info" v-if="tag">
          <div class="tag-title">
            <p class="tag-name">{{tag.name}}</p>
            <tag-options :tag="tag"/>
          </div>
          <div class="tag-desc" v-if="tag.desc">{{tag.description}}</div>
        </div>
        <h3 v-if="loading_posts">
          <p>Cargando posts...</p>
        </h3>
        <div id="feed">
          <div
            class="tag-posts"
            v-masonry
            transition-duration=".3s"
            item-selector=".card"
            fit-width="true"
          >
            <card
              v-for="post in posts"
              :key="post.id"
              :post="post"
              v-masonry-tile
              class="little"
              size="little"
            ></card>
          </div>
          <h3 v-if="loading_more_posts">
            <p>Cargando mas posts...</p>
          </h3>
          <intersector @intersect="load_more_posts"></intersector>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import axios from "axios";
import { mapGetters } from "vuex";

import Top from "@/components/Top";
import Card from "@/components/Card/_Card";
import Intersector from "@/components/Intersector";
import TagOptions from "@/components/Tag/TagOptions";

export default {
  name: "TagInfo",
  components: { Top, Card, Intersector, TagOptions },
  data: () => ({
    tag: null,
    posts: [],
    loading_tag: false,
    loading_posts: false,
    loading_more_posts: false,
    last_page: false,
    next: null
  }),
  computed: {
    ...mapGetters("tag", ["tags"]),
    subbed() {
      const tag_names = this.tags.map(o => o.name.toLowerCase());
      return tag_names.includes(this.tag.name.toLowerCase());
    },
    tag_name() {
      return this.$route.params.name;
    }
  },
  methods: {
    async load_tag() {
      this.loading_tag = true;
      try {
        const { data: tag } = await axios.get(`/api/v1/tags/${this.tag_name}`);
        const e_tag = _.find(this.tags, x => x.id == tag.id);
        if (e_tag != undefined) {
          tag.sub_level = e_tag.sub_level;
        }
        this.tag = tag;
        this.load_posts();
      } catch (e) {
        if (e.response && e.response.status == 404) {
          this.$router.replace(`/search/tag:${this.tag_name}`);
        } else {
          throw e;
        }
      }
      this.loading_tag = false;
    },
    async load_posts() {
      this.loading_posts = true;
      const { data: res } = await axios.get(
        `/api/v1/tags/${this.tag_name}/posts`
      );
      this.posts = res.items;
      this.last_page = res.last_page;
      this.next = res.next;
      this.loading_posts = false;
    },
    async load_more_posts() {
      if (
        this.last_page ||
        this.loading_tag ||
        this.loading_posts ||
        this.loading_more_posts
      )
        return;
      this.loading_more_posts = true;
      const { data: res } = await axios.get(
        `/api/v1/tags/${this.tag_name}/posts`,
        { params: { before: this.next } }
      );
      this.posts.push(...res.items);
      this.last_page = res.last_page;
      this.next = res.next;
      this.loading_more_posts = false;
    }
  },
  mounted() {
    this.load_tag();
  },
  watch: {
    $route: function() {
      this.tag = null;
      this.posts = [];
      this.next = null;
      this.last_page = false;

      this.load_tag();
    }
  }
};
</script>

<style lang="scss" scoped>
#wrapper {
  align-items: flex-start;
  justify-content: center;
}
.tag-info {
  margin-bottom: 20px;
  .tag-title {
    display: flex;
    align-items: center;
  }
  .tag-name {
    font-weight: 400;
    font-size: 2em;
    color: #fff;
    margin-right: 10px;
  }
}
</style>
