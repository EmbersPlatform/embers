<template>
  <div class="reactions-modal">
    <div class="loading-text" v-if="loading_stats">Cargando...</div>
    <div class="reactions-list" v-else>
      <div
        class="reaction"
        @click="select_reaction('all')"
        :active="'all' == current_reaction"
      >Todas</div>
      <div
        v-for="(count, reaction) in stats"
        class="reaction"
        @click="select_reaction(reaction)"
        :key="reaction"
        :active="reaction == current_reaction"
      >
        <img :src="`/img/emoji/${reaction}.svg`" :alt="reaction" class="emoji">
        {{ count }}
      </div>
      <button
        data-button-size="medium"
        data-button-font="medium"
        class="button close-reactions-modal"
        @click="$emit('close')"
      >
        <i class="fas fa-chevron-left"></i>
      </button>
    </div>
    <div class="reactions-users" v-if="!loading_stats">
      <div class="loading-text" v-if="loading_reactions">Cargando reacciones...</div>
      <div class="reactions-users-list" v-if="!loading_reactions">
        <router-link
          :to="`/@${reaction.user.username}`"
          class="reaction-user"
          v-for="reaction in reactions"
          :key="reaction.user.id"
          @click.native="$emit('close')"
        >
          <avatar :avatar="reaction.user.avatar.small"></avatar>
          <div class="reaction-icon">
            <img :src="`/img/emoji/${reaction.name}.svg`" class="emoji">
          </div>
          <strong>{{ reaction.user.username }}</strong>
        </router-link>
        <intersector @intersect="load_more_reactions"/>
        <div class="loading-text" v-if="loading_more_reactions">Cargando mas reacciones...</div>
      </div>
    </div>
  </div>
</template>

<script>
import axios from "axios";
import avatar from "@/components/Avatar";
import Intersector from "@/components/Intersector";

export default {
  name: "ReactionsModal",
  components: { avatar, Intersector },
  props: {
    post_id: {
      type: String,
      required: true
    }
  },
  data() {
    return {
      stats: [],
      reactions: [],
      loading_stats: false,
      loading_reactions: false,
      loading_more_reactions: false,
      last_page: false,
      next: null,
      current_reaction: "all"
    };
  },
  methods: {
    selectReaction(reaction) {
      this.current_reaction = reaction;
    },
    async fetch_stats() {
      this.loading_stats = true;
      try {
        const { data: stats } = await axios.get(
          `/api/v1/posts/${this.post_id}/reactions/overview`
        );
        this.stats = stats;
        this.fetch_reactions();
      } catch (e) {
        throw e;
      }
      this.loading_stats = false;
    },
    async fetch_reactions() {
      this.loading_reactions = true;
      this.reactions = [];
      try {
        const { data: res } = await axios.get(
          `/api/v1/posts/${this.post_id}/reactions/${this.current_reaction}`
        );
        this.reactions = res.entries;
        this.last_page = res.last_page;
        this.next = res.next;
      } catch (e) {
        throw e;
      }
      this.loading_reactions = false;
    },
    async load_more_reactions() {
      if (this.loading_stats || this.loading_more_reactions || this.last_page)
        return;
      this.loading_more_reactions = true;
      try {
        const { data: res } = await axios.get(
          `/api/v1/posts/${this.post_id}/reactions/${this.current_reaction}`
        );
        this.reactions.push(res.entries);
        this.last_page = res.last_page;
        this.next = res.next;
      } catch (e) {
        throw e;
      }
      this.loading_more_reactions = false;
    },
    select_reaction(reaction) {
      this.current_reaction = reaction;
      this.fetch_reactions();
    }
  },
  mounted() {
    this.fetch_stats();
  }
};
</script>

<style lang="scss" scoped>
.avatar {
  width: 32px;
  height: 32px;
}
.reaction-user {
  .reaction-icon {
    position: absolute;
    left: 20px;
    bottom: 0;
    width: 20px;
    height: 20px;
    display: block;
    box-sizing: border-box;
    padding: 3px;
    border-radius: 50%;
    background: #1b1c1f;
    overflow: hidden;
    img {
      width: 100%;
      height: 100%;
      display: block;
    }
  }
}
.loading-text {
  width: 100%;
  text-align: center;
  padding: 5px 10px;
}
</style>
