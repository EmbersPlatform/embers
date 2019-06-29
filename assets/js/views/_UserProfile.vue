<template>
  <div id="board">
    <template v-if="!loading">
      <div id="heading" class="user">
        <Top></Top>
        <profile-header :user="user" />
      </div>
      <div id="wrapper">
        <router-view></router-view>
      </div>
    </template>
  </div>
</template>

<script>
import SideModules from "@/components/SideModules/UserProfile";
import Top from "@/components/Top";
import UserCard from "@/components/UserCard";
import user from "../api/user";
import avg_color from "fast-average-color";

import ProfileHeader from "@/components/ProfileHeader";

export default {
  components: {
    SideModules,
    Top,
    UserCard,
    ProfileHeader
  },

  data() {
    return {
      loading: false,
      bg_color: "transparent",
      bg_color_retrieved: false
    };
  },
  computed: {
    user() {
      return this.$store.state.userProfile;
    }
  },
  methods: {
    fetchUser() {
      this.$store.dispatch("setUserProfile", null);
      this.loading = true;

      user
        .get(this.$route.params.username)
        .then(res => {
          if (res.data.canonical != this.$route.params.username.toLowerCase()) {
            return;
          }
          this.$store.dispatch(
            "title/update",
            "@" + this.$route.params.username + " en Embers"
          );
          this.$store.dispatch("setUserProfile", res.data);
        })
        .catch(e => {
          console.log(e);
        })
        .finally(() => (this.loading = false));
    }
  },
  watch: { $route: "fetchUser" },

  /**
   * Triggered when a component instance is created
   */
  created() {
    this.fetchUser();
  }
};
</script>

<style lang="scss" scoped>
#heading {
  background: none !important;
}
#wrapper {
  margin-top: 20px !important;
}
</style>
