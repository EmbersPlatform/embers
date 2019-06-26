<template>
  <div id="wrapper" data-layout-type="column">
    <div class="block" data-layout-type="column">
      <h2>Tags bloqueados</h2>
    </div>
    <div class="block new-block" data-layout-type="column">
      <form @submit.prevent="add_tag">
        <input type="text" v-model="new_block_name" placeholder="Tag a bloquear, sin el #">
        <input
          type="submit"
          class="button"
          data-button-important
          data-button-size="medium"
          data-button-text="medium"
          @click.prevent="add_block"
          value="Bloquear"
        >
      </form>
    </div>
    <div class="block" data-layout-type="column" v-if="!loading && tags.length">
      <div class="tag-item" v-for="tag in tags" :key="tag.id">
        <div class="tag-header">
          <router-link :to="`/tag/${tag.name}`" class="tag-name">
            <i class="fas fa-hashtag"/>
            {{tag.name}}
          </router-link>
          <div class="tag-actions">
            <button class="button" data-button-size="medium" @click="unblock_tag(tag)">Desbloquear</button>
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
        <p>No bloqueaste a ningun tag</p>
      </h3>
    </div>
  </div>
</template>

<script>
import axios from "axios";
import _ from "lodash";

import Intersector from "@/components/Intersector";

export default {
  name: "Tags",
  components: { Intersector },
  data() {
    return {
      tags: [],
      loading: false,
      loading_more: false,
      last_page: false,
      next: null,
      error: null,
      new_block_name: ""
    };
  },

  methods: {
    async load_tags() {
      this.loading = true;
      try {
        const { data: res } = await axios.get(`/api/v1/tag_blocks/list`);
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
        const { data: res } = await axios.get(`/api/v1/tag_blocks/list`, {
          params: { after: this.next }
        });
        this.tags.push(res.items);
        this.last_page = res.last_page;
        this.next = res.next;
      } catch (e) {
        this.error = "Hubo un error al cargar los tags";
      }
      this.loading_more = false;
    },
    async add_block() {
      const tag_name = this.new_block_name;
      await axios.post(`/api/v1/tag_blocks`, { name: tag_name });
      const { data: tag } = await axios.get(`/api/v1/tags/${tag_name}`);
      const existing_tag = _.find(this.tags, x => x.name == tag.name);
      if (undefined == existing_tag) {
        this.tags.push(tag);
      }
      this.new_block_name == null;
    },
    async unblock_tag(tag) {
      await axios.delete(`/api/v1/tag_blocks/${tag.id}`);
      this.tags = this.tags.filter(x => x.id != tag.id);
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

.new-block {
  margin-bottom: 20px;
  form {
    width: 100%;
    display: flex;
    align-items: center;
    input[type="text"] {
      flex: 1 auto;
      &::placeholder {
        color: #ffffff99;
      }
    }
    input[type="submit"] {
      width: fit-content;
    }
  }
}
</style>
