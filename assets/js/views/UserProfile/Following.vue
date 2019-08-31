<template>
  <div id="content">
    <h3 class="page-title">Usuarios seguidos por {{user.username}}</h3>
    <div class="users-list">
      <user-card v-for="user in following" :key="user.id" :user="user" type="compact" no_stats />
    </div>
    <h3 v-if="loading_more">
      <p>Cargando mas...</p>
    </h3>
    <intersector @intersect="load_more" />
  </div>
</template>

<script>
import axios from "axios";

import Intersector from "@/components/Intersector";
import UserCard from "@/components/UserCard";

export default {
  name: "ProfileFollowing",
  components: { Intersector, UserCard },
  data: () => ({
    following: [],
    last_page: false,
    next: null,
    loading: false,
    loading_more: false
  }),
  computed: {
    user() {
      return this.$store.state.userProfile;
    }
  },
  methods: {
    async get_following() {
      console.log("load following", this.user);
      this.loading = true;
      const { data: res } = await axios.get(
        `/api/v1/following/${this.user.id}/list`
      );
      this.following = res.items;
      this.last_page = res.last_page;
      this.next = res.next;
      this.loading = false;
    },
    async load_more() {
      if (this.last_page || this.loading || this.loading_more) return;
      this.loading_more = true;
      const { data: res } = await axios.get(
        `/api/v1/following/${this.user.id}/list`,
        { params: { after: this.next } }
      );
      const body = document.getElementsByTagName("html")[0];
      const old_scroll = body.scrollTop;

      this.following.push(...res.items);
      this.last_page = res.last_page;
      this.next = res.next;

      this.$nextTick(() => {
        body.scrollTop = old_scroll;
      });
      this.loading_more = false;
    }
  },
  mounted() {
    this.get_following();
  }
};
</script>

<style lang="scss" scoped>
@import "~@/../sass/base/_variables.scss";
.page-title {
  margin-left: 20px;
  font-size: 1.5em;
  margin-bottom: 1em;
}
.users-list {
  display: flex;
  flex-wrap: wrap;
  justify-content: center;

  .profile {
    width: 33%;
    max-width: 315px;
    box-sizing: border-box;
    @media #{$query-mobile} {
      width: 100%;
      max-width: 100%;
    }
  }
}
</style>

