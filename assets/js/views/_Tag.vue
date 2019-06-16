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
            <button
              class="button"
              data-button-size="medium"
              data-button-text="medium"
              :data-button-important="subbed"
              @click="sub_tag"
            >
              <i class="fas fa-thumbtack"></i>
            </button>
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
            <intersector @intersect="load_more_posts"></intersector>
            <h3 v-if="loading_more_posts">
              <p>Cargando mas posts...</p>
            </h3>
          </div>
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

export default {
  name: "TagInfo",
  components: { Top, Card, Intersector },
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
      const tag_names = this.tags.map(o => o.name);
      return tag_names.includes(this.tag.name);
    },
    tag_name() {
      return this.$route.params.name;
    }
  },
  methods: {
    async load_tag() {
      this.loading_tag = true;
      const { data: tag } = await axios.get(`/api/v1/tags/${this.tag_name}`);
      this.tag = tag;
      this.loading_tag = false;
      this.load_posts();
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
      this.loading_posts = true;
      const { data: res } = await axios.get(
        `/api/v1/tags/${this.tag_name}/posts`
      );
      this.posts.push(res.items);
      this.last_page = res.last_page;
      this.next = res.next;
      this.loading_posts = false;
    },
    async sub_tag() {
      try {
        if (!this.subbed) {
          let tag = (await axios.post(`/api/v1/subscriptions/tags`, {
            id: this.tag.id
          })).data;
          this.$store.dispatch("tag/add", tag);
        } else {
          await axios.delete(`/api/v1/subscriptions/tags/${this.tag.id}`);
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
