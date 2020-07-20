<template>
  <div
    id="feed"
    :class="{'renderbox': loading || refreshing}"
    :data-renderbox-message="[loading ? 'Cargando posts...' : 'Actualizando feed...']"
    :data-renderbox-top="refreshing"
    ref="postList"
    v-shortkey.once="['n']"
    @shortkey="jump_to_next_post()"
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
        <template v-for="(post, index) in concated_posts">
          <Card
            v-if="post.isShared"
            v-masonry-tile
            class="little"
            :post="post.source"
            :showThumbnail="showThumbnail"
            :key="post.id"
            :sharer="post.user"
            :isShared="post.isShared"
            :size="size"
            :removable="removables"
            @deleted="remove_post(post.id)"
            :ref="`item-${index}`"
            @intersect="post_in_view(index)"
            @leave="post_leaves_view(index)"
            @medialoaded="redraw_masonry"
          ></Card>
          <Card
            v-else
            :post="post"
            v-masonry-tile
            class="little"
            :key="post.id"
            :showThumbnail="showThumbnail"
            :size="size"
            :removable="removables"
            @deleted="remove_post(post.id)"
            :ref="`item-${index}`"
            @intersect="post_in_view(index)"
            @leave="post_leaves_view(index)"
          ></Card>
        </template>
      </div>
    </template>
    <template v-else v-for="(post, index) in concated_posts">
      <Card
        v-if="post.isShared"
        :post="post.source"
        :showThumbnail="showThumbnail"
        :key="post.id"
        :sharers="post.sharers"
        :isShared="post.isShared"
        :size="size"
        :removable="removables"
        @deleted="remove_post(post.id)"
        :ref="`item-${index}`"
        @intersect="post_in_view(index)"
        @leave="post_leaves_view(index)"
      ></Card>
      <Card
        v-else
        :post="post"
        :key="post.id"
        :showThumbnail="showThumbnail"
        :size="size"
        :removable="removables"
        @deleted="remove_post(post.id)"
        :ref="`item-${index}`"
        @intersect="post_in_view(index)"
        @leave="post_leaves_view(index)"
      ></Card>
    </template>
    <intersector @intersect="loadMore" style="height: 10px;" />
    <template v-if="reachedBottom && !loading && !refreshing">
      <h3 v-html="formattedNoResults" v-if="posts.length === 0"></h3>
      <h3 v-html="formattedReachedBottom" v-else></h3>
    </template>
  </div>
</template>

<script>
import _ from "lodash";

import feed from "../api/feed";

import formatter from "@/lib/formatter";

import EventBus from "@/lib/event_bus";

import Card from "./Card/_Card";
import Intersector from "./Intersector";

import { mapGetters } from "vuex";

export default {
  props: {
    name: {
      type: String
    },
    filters: {
      required: false
    },
    size: {
      type: String
    },
    removables: {
      type: Boolean,
      default: false
    }
  },
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
      posts: [],
      posts_in_viewport: [],
      shortcuts_enabled: false
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
    },
    concated_posts() {
      const posts = _.uniqBy(this.posts, "id");
      return this.concat_post(posts);
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
    redraw_masonry() {
      this.$redrawVueMasonry("#masonry");
    },
    // Concatena shared post que se siguen el uno al otro
    // TODO concatenar post entre peticiones loadmore y vista actual
    concat_post(items) {
      const { posts } = items.reduce(
        (acc, post, index, posts) => {
          if (post.related_to == null) {
            const there_is_no_shares =
              _.find(posts, x => x.related_to && x.related_to.id == post.id) ==
              undefined;
            if (there_is_no_shares) {
              acc.posts.push(post);
            }
          } else if (post.body != null && post.body != "") {
            acc.posts.push(post);
          } else {
            if (_.find(acc.remaining, x => x.id == post.id) == undefined) {
              // Skip if current post was removed from remaining posts
              return acc;
            }
            if (
              _.find(
                acc.remaining,
                x => x.related_to && x.related_to.id == post.related_to.id
              ) != undefined
            ) {
              let sharers = [post.user];
              let activities_ids = [post.id];
              const other_related = acc.remaining.filter(
                p =>
                  p.related_to &&
                  p.related_to.id == post.related_to.id &&
                  (post.body == null || post.body == "")
              );
              const other_sharers = other_related.map(p => p.user);
              sharers.push(...other_sharers);
              activities_ids.push(...other_related.map(p => p.id));
              const is_new = post.new;
              post = post.related_to;
              post.new = is_new;
              post.sharers = _.uniqBy(sharers, "id");
              post.activities_ids = _.uniq(activities_ids);
              acc.remaining = acc.remaining.filter(
                x => !other_related.includes(x)
              );
              acc.posts.push(post);
            }
          }
          return acc;
        },
        { posts: [], remaining: items }
      );
      return posts;
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
          var _res = res.items;
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
          var _res = res.items;
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
    },
    prepend_new_posts() {
      const new_posts = this.$store.state.feed.new_posts;
      const old_posts = this.posts.map(x => {
        x.new = false;
        return x;
      });
      this.posts = [...new_posts, ...old_posts];
      this.$store.dispatch("reset_new_posts");
    },
    remove_post(id) {
      this.posts = this.posts.filter(post => {
        let related;
        if (post.related_to) {
          related = post.related_to.id != id;
        } else {
          related = true;
        }
        const is_id = post.id != id;
        return is_id && related;
      });
    },
    post_in_view(idx) {
      this.posts_in_viewport.push(idx);
    },
    post_leaves_view(idx) {
      this.posts_in_viewport = this.posts_in_viewport.filter(x => x != idx);
    },
    jump_to_next_post() {
      let idx = this.posts_in_viewport[0];
      let next_post = this.$refs[`item-${idx + 1}`][0].$el;
      next_post.scrollIntoView({ behavior: "smooth" });
    }
  },
  mounted() {
    document.addEventListener("keydown", this._keyListener.bind(this));
  },
  beforeDestroy() {
    document.removeEventListener("keydown", this._keyListener);
  },

  /**
   * Triggered when a component instance is created
   */
  created() {
    this.reload();
    this.$root.$on("refresh_feed", this.reload);
    this.$root.$on("addFeedPost", new_post => this.posts.unshift(new_post));
    this.$root.$on("prepend_new_posts", this.prepend_new_posts);
    this.noMasonry(); //check if can show masonry at page load
    window.addEventListener("resize", this.noMasonry);

    EventBus.$on("medialoaded", e => {
      this.redraw_masonry()
    })
  },
  beforeDestroy() {
    window.removeEventListener("resize", this.noMasonry);
    this.$root.$off("prepend_new_posts", this.prepend_new_posts);
  }
};
</script>
