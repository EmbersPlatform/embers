<template>
  <div id="board">
    <div id="heading">
      <Top></Top>
    </div>
    <div id="wrapper">
      <div id="content" data-layout-type="masonry">
        <div
          id="feed"
          :class="{renderbox : (loading || loadingMore), 'showing' : !loading && (hasPost)}"
          :data-renderbox-message="[loadingMore ? 'Cargando más resultados...' : 'Buscando...']"
          v-infinite-scroll="loadMore"
          :infinite-scroll-disabled="infiniteScrollStill"
        >
          <h3>
            <p>Posts:</p>
          </h3>
          <div
            v-if="isMasonry"
            id="masonry"
            v-masonry
            transition-duration=".3s"
            item-selector=".little"
            fit-width="true"
          >
            <Card
              v-for="post in results"
              :key="post.id"
              v-masonry-tile
              class="little"
              :post="post"
              size="little"
            ></Card>
          </div>
          <Card v-else v-for="post in results" :key="post.id" :post="post" size="medium"></Card>
          <h3 v-if="(!hasPost) || last_page" :class="{'bottom': last_page && (hasPost)}">
            <p v-html="formatted"></p>
          </h3>
        </div>
      </div>
    </div>
  </div>
</template>
<script>
import searchApi from "../api/search";
import Card from "../components/Card/_Card";
import UserCard from "../components/UserCard";
import Top from "../components/Top";
import formatter from "@/lib/formatter";

import _ from "lodash";

export default {
  components: {
    Card,
    UserCard,
    Top
  },
  data() {
    return {
      loading: true,
      loadingMore: false,
      searchParams: null,
      results: [],
      next_cursor: null,
      last_page: false,
      previousScrollPosition: 0,
      isMasonry: true
    };
  },
  computed: {
    infiniteScrollStill() {
      return this.loading || this.last_page;
    },
    hasPost() {
      if (this.results.length < 1) {
        return false;
      }
      return true;
    },
    formatted() {
      return this.last_page && this.hasPost
        ? formatter.format("No hay mas resultados :eggplant:")
        : "No pudimos encontrar lo que buscabas :c";
    }
  },
  methods: {
    noMasonry() {
      if (window.innerWidth > 644) {
        this.isMasonry = true;
        return;
      }
      this.isMasonry = false;
      return;
    },
    getPreviousScrollPosition() {
      this.previousScrollPosition = $(window).scrollTop();
    },
    search() {
      if (this._inactive || !this.searchParams) {
        return;
      }
      this.results = [];
      this.loading = true;
      searchApi
        .search(this.searchParams)
        .then(res => {
          this.results = res.items;
          this.next_cursor = res.next;
          this.last_page = res.last_page;
        })
        .finally(() => (this.loading = false));
    },
    loadMore: _.debounce(function() {
      // Debounce the function so it is not called multiple times
      if (this.infiniteScrollStill) {
        return;
      }
      this.loadingMore = true;
      this.getPreviousScrollPosition();
      searchApi
        .search(this.searchParams, { before: this.next_cursor })
        .then(res => {
          if (this._inactive) {
            return;
          }
          this.results = [...this.results.items, ...res.items];
          this.next_cursor = res.next;
          this.last_page = res.last_page;
        })
        .finally(() => {
          window.scrollTo(0, this.previousScrollPosition);
          this.loadingMore = false;
        });
    }, 1000)
  },
  watch: {
    $route: function(to, from) {
      this.searchParams = to.params.searchParams;
      this.$root.$emit("search-update", to.params.searchParams);
      this.search();
    }
  },
  created() {
    this.searchParams = this.$route.params.searchParams;
    this.search();

    this.$root.$on("search", params => {
      this.searchParams = params;
      this.search();
    });
    this.noMasonry(); //check if can show masonry at page load
    window.addEventListener("resize", this.noMasonry);
  },
  beforeDestroy() {
    window.removeEventListener("resize", this.noMasonry);
  }
};
</script>
