<template>
  <div id="wrapper" data-layout-type="column">
    <div class="block" data-layout-type="column">
      <h2>Mis Tags</h2>
    </div>
    <div class="block" data-layout-type="column" v-if="!loading && tags.length">
      <div class="tag-item" v-for="tag in tags" :key="tag.id">
        <div class="tag-header">
          <router-link :to="`/tag/${tag.name}`" class="tag-name">
            <i class="fas fa-hashtag"/>
            {{tag.name}}
          </router-link>
          <div class="tag-actions">
            <tag-options :tag="tag"/>
          </div>
        </div>
        <p class="tag-desc" v-if="tag.description">{{tag.description}}</p>
      </div>
      <intersector @intersect="load_more"/>
      <h3 v-if="loading_more">
        <p>Cargando tags...</p>
      </h3>
    </div>
    <div v-else>
      <h3>
        <p>No estas suscripto a ningun tag</p>
      </h3>
    </div>
  </div>
</template>

<script>
import axios from "axios";
import _ from "lodash";

import Intersector from "@/components/Intersector";
import TagOptions from "@/components/Tag/TagOptions";

export default {
  name: "Tags",
  components: { Intersector, TagOptions },
  data() {
    return {
      tags: null,
      loading: false,
      loading_more: false,
      last_page: false,
      next: null,
      error: null
    };
  },

  methods: {
    async load_tags() {
      this.loading = true;
      try {
        const { data: res } = await axios.get(
          `/api/v1/subscriptions/tags/list`
        );
        this.tags = res.items;
        this.last_page = res.last_page;
        this.next = res.next;
      } catch (e) {
        this.error = "Hubo un error al cargar los tags";
      }
      this.loading = false;
    },
    async load_more() {
      if (this.last_page || this.loading || this.loading_more) return;
      this.loading_more = true;
      try {
        const { data: res } = await axios.get(
          `/api/v1/subscriptions/tags/list`,
          { params: { after: this.next } }
        );
        this.tags.push(res.items);
        this.last_page = res.last_page;
        this.next = res.next;
      } catch (e) {
        this.error = "Hubo un error al cargar los tags";
      }
      this.loading_more = false;
    },
    async remove_tag(tag) {
      await axios.delete(`/api/v1/subscriptions/tags/${tag.id}`);
      const index = this.tags.indexOf(tag);
      this.tags[index].sub_level = -1;
    },
    async pin_tag(tag) {
      await axios.post(`/api/v1/subscriptions/tags/`, { id: tag.id, level: 0 });
      const index = this.tags.indexOf(tag);
      this.tags[index].sub_level = 0;
    },
    async sub_tag(tag) {
      await axios.post(`/api/v1/subscriptions/tags/`, { id: tag.id });
      const index = this.tags.indexOf(tag);
      this.tags[index].sub_level = 1;
    }
  },

  mounted() {
    this.load_tags();
  }
};
</script>

<style lang="scss" scoped>
.tag-item {
  padding: 10px;
  border: 1px solid #ffffff10;
  margin-bottom: 10px;

  .tag-header {
    display: flex;
    width: 100%;
  }

  .tag-name {
    color: #ffffffcc;
    font-weight: 400;
    font-size: 1.2em;
    margin: 0 !important;
    flex-grow: 1;
  }

  .tag-actions {
    display: flex;
    flex-wrap: wrap;
    justify-content: flex-end;
  }

  .tag-desc {
    margin: 0;
  }
}
</style>
