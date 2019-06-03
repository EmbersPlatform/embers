<template>
  <div id="content" data-layout-type="single-column">
    <ToolBox v-if="isSelfProfile"></ToolBox>
    <Feed v-if="user" :name="`user/${user.id}`"></Feed>
    <intersector @intersect="load_more" style="height: 20px;"/>
    <h3 v-if="!last_page">Cargando mas resultados...</h3>
    <template v-if="last_page && !loading && !loading_more">
      <h3 v-html="formattedNoResults" v-if="posts.length === 0"></h3>
      <h3 v-html="formattedReachedBottom" v-else></h3>
    </template>
  </div>
</template>

<script>
import axios from "axios";
import feed from "@/api/feed";
import ToolBox from "@/components/ToolBox/_ToolBox";
import Feed from "@/components/Feed";
import user from "@/api/user";
import Intersector from "@/components/Intersector";

import formatter from "@/lib/formatter";
import { concat_post } from "@/lib/posts";
import { mapState } from "vuex";

export default {
  components: {
    ToolBox,
    Feed,
    Intersector
  },

  data() {
    return {
      loading: false,
      loading_more: false,
      posts: [],
      last_page: false,
      next_cursor: null
    };
  },
  computed: {
    ...mapState({ user: state => state.userProfile }),
    isSelfProfile() {
      if (!this.$store.getters.user) {
        return false;
      }
      return this.$route.params.name === this.$store.getters.user.name;
    },
    formattedReachedBottom() {
      return formatter.format("Bienvenidos al fin del mundo :eggplant:");
    },

    formattedNoResults() {
      return formatter.format(
        "¡Qué vacío está esto! [¿Quieres descubrir cosas nuevas?](/discover#recent) :smirk:"
      );
    }
  },
  methods: {
    load_posts() {
      this.loading = true;
      axios
        .get("/api/v1/feed/user/" + this.user.id)
        .then(res => {
          console.log(res.data);
          if (res.data.items.length) {
            var _res = concat_post(res.data.items);
            this.posts = _res;
          }
          this.next_cursor = res.data.next;
          this.last_page = res.data.last_page;
        })
        .finally(() => {
          this.loading = false;
        });
    },
    load_more() {
      if (this.loading || this.last_page) return;
      this.loading_more = true;
      axios
        .get("/api/v1/feed/user/" + this.user.id, {
          params: { before: this.next_cursor }
        })
        .then(res => {
          if (res.data.items.length) {
            var _res = concat_post(res.data.items);
            this.posts = [...this.posts, ..._res];
          }
          this.next_cursor = res.data.next;
          this.last_page = res.data.last_page;
        })
        .finally(() => {
          this.loading_more = false;
        });
    }
  },
  watch: {
    $route() {
      this.load_posts();
    }
  },

  /**
   * Triggered when a component instance is created
   */
  created() {
    this.load_posts();
  }
};
</script>
