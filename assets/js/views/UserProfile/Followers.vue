<template>
  <div id="content">
    <div class="users-list">
      <user-card v-for="user in followers" :key="user.id" :user="user" type="compact" no_stats />
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
  name: "ProfileFollowers",
  components: { Intersector, UserCard },
  data: () => ({
    followers: [],
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
    async get_followers() {
      console.log("load followers", this.user);
      this.loading = true;
      const { data: res } = await axios.get(
        `/api/v1/friends/${this.user.id}/list`
      );
      this.followers = res.items;
      this.last_page = res.last_page;
      this.next = res.next;
      this.loading = false;
    },
    async load_more() {
      if (this.last_page || this.loading || this.loading_more) return;
      this.loading_more = true;
      const { data: res } = await axios.get(
        `/api/v1/friends/${this.user.id}/list`,
        { params: { after: this.next } }
      );
      const body = document.getElementsByTagName("html")[0];
      const old_scroll = body.scrollTop;

      this.followers.push(...res.items);
      this.last_page = res.last_page;
      this.next = res.next;

      this.$nextTick(() => {
        body.scrollTop = old_scroll;
      });
      this.loading_more = false;
    }
  },
  mounted() {
    this.get_followers();
  }
};
</script>

<style lang="scss" scoped>
.users-list {
  display: flex;
  flex-wrap: wrap;

  .profile {
    width: 33%;
    max-width: 315px;
    box-sizing: border-box;
  }
}
</style>

