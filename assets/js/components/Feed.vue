<template>
  <div
    id="feed"
    :class="{'renderbox': loading || refreshing}"
    :data-renderbox-message="[loading ? 'Cargando posts...' : 'Actualizando feed...']"
    :data-renderbox-top="refreshing"
    ref="postList"
  >
    <template v-if="isMasonry">
      <div
        v-if="first_load"
        id="masonry"
        ref="masonry"
        v-masonry
        transition-duration=".3s"
        item-selector=".little"
        fit-width="true"
      >
        <template v-for="(post, index) in posts">
          <Card
            v-if="post.isShared"
            v-masonry-tile
            class="little"
            :post="post.source"
            :showThumbnail="showThumbnail"
            :key="index"
            :sharer="post.user"
            :isShared="post.isShared"
            :size="size"
          ></Card>
          <Card
            v-else
            :post="post"
            v-masonry-tile
            class="little"
            :key="post.id"
            :showThumbnail="showThumbnail"
            :size="size"
          ></Card>
        </template>
      </div>
    </template>
    <template v-else v-for="(post, index) in posts">
      <Card
        v-if="post.isShared"
        :post="post.source"
        :showThumbnail="showThumbnail"
        :key="index"
        :sharers="post.sharers"
        :isShared="post.isShared"
        :size="size"
      ></Card>
      <Card v-else :post="post" :key="post.id" :showThumbnail="showThumbnail" :size="size"></Card>
    </template>
    <intersector @intersect="loadMore" style="height: 10px;"/>
    <template v-if="reachedBottom && !loading && !refreshing">
      <h3 v-html="formattedNoResults" v-if="posts.length === 0"></h3>
      <h3 v-html="formattedReachedBottom" v-else></h3>
    </template>
  </div>
</template>

<script>
import feed from "../api/feed";

import formatter from "@/lib/formatter";

import Card from "./Card/_Card";
import Intersector from "./Intersector";

import { mapGetters } from "vuex";

export default {
  props: ["name", "filters", "size"],
  components: {
    Card,
    Intersector
  },

  /**
   * Component data
   */
  data() {
    return {
      loading: false,
      next_activity: null,
      reachedBottom: false,
      previousScrollPosition: 0,
      refreshing: false,
      first_load: false,
      isMasonry: true,
      posts: []
    };
  },
  computed: {
    showThumbnail() {
      return !!this.$store.getters.settings.content_lowres_images;
    },

    formattedReachedBottom() {
      return formatter.format("Bienvenidos al fin del mundo :eggplant:");
    },

    formattedNoResults() {
      return formatter.format(
        "¡Qué vacío está esto! [¿Quieres descubrir cosas nuevas?](/discover#recent) :smirk:"
      );
    },
    infiniteScrollStill() {
      return this.loading || this.reachedBottom;
    }
  },
  methods: {
    noMasonry() {
      if (this.size == "little" && window.innerWidth > 644) {
        this.isMasonry = true;
        return;
      }
      this.isMasonry = false;
      return;
    },
    // Concatena shared post que se siguen el uno al otro
    // TODO concatenar post entre peticiones loadmore y vista actual
    concat_post(items) {
      outer: for (var i = 0; i < items.length; i++) {
        if (items[i].isShared) {
          var sharers = [items[i].user];
          inner: for (var o = i + 1; o < items.length; o++) {
            if (items[o].isShared) {
              if (items[o].source.id == items[i].source.id) {
                //is another shared from same post, save and delete
                sharers.push(items[o].user);
                items.splice(o, 1);
                o -= 1;
              }
            } else {
              if (items[o].id == items[i].source.id) {
                //is original post
                items.splice(o, 1);
                break inner;
              }
            }
          }
          items[i]["sharers"] = sharers;
        }
      }
      return items;
    },
    getPreviousScrollPosition() {
      this.previousScrollPosition = $(window).scrollTop();
    },
    reload() {
      this.refreshing = true;
      this.first_load = false;
      feed
        .get(this.name, { filters: this.filters })
        .then(res => {
          var _res = this.concat_post(res.items);
          if (this._inactive) {
            return;
          }
          this.posts = _res;
          if (res.items.length) {
            this.next_activity = res.next;
          }
          this.reachedBottom = res.last_page;
          this.$store.dispatch("resetNewActivity");
        })
        .finally(() => {
          this.refreshing = false;
          this.first_load = true;
        });
    },

    /**
     * Loads the next page of the current feed
     */
    loadMore() {
      this.do_load_more();
    },
    do_load_more() {
      if (this.infiniteScrollStill || !this.first_load) {
        return;
      }
      this.loading = true;
      this.getPreviousScrollPosition();
      feed
        .get(this.name, {
          before: this.next_activity,
          filters: this.filters
        })
        .then(res => {
          var _res = this.concat_post(res.items);
          if (this._inactive) {
            return;
          }
          if (res.items.length) {
            this.posts = [...this.posts, ..._res];
            this.next_activity = res.next;
          }
          this.reachedBottom = res.last_page;
        })
        .finally(() => {
          window.scrollTo(0, this.previousScrollPosition);
          this.loading = false;
        });
    }
  },

  /**
   * Triggered when a component instance is created
   */
  created() {
    this.reload();
    this.$root.$on("refresh_feed", this.reload);
    this.$root.$on("addFeedPost", new_post => this.posts.unshift(new_post));
    this.$root.$on("prepend_new_posts", () => {
      const new_posts = this.$store.state.feed.new_posts;
      const old_posts = this.posts.map(p => {
        p.new = false;
        return p;
      });
      this.posts = [...new_posts, ...old_posts];
    });
    this.noMasonry(); //check if can show masonry at page load
    window.addEventListener("resize", this.noMasonry);
  },
  beforeDestroy() {
    window.removeEventListener("resize", this.noMasonry);
  }
};
</script>
