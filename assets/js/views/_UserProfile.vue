<template>
  <div id="board">
    <template v-if="!loading">
      <div id="heading" class="user">
        <template>
          <hr v-if="user.cover" :style="'background-image: url('+user.cover+');'">
          <hr v-else style="background-image: url(/cover/default.jpg);">
        </template>
        <Top></Top>
        <UserCard :user="user" type="wide"></UserCard>
      </div>
      <div id="wrapper">
        <SideModules ref="side"></SideModules>
        <router-view></router-view>
      </div>
    </template>
  </div>
</template>

<script>
import SideModules from "@/components/SideModules/UserProfile";
import Top from "@/components/Top";
import UserCard from "@/components/UserCard";
import user from "@/api/user";

import formatter from "@/lib/formatter";

export default {
  components: {
    SideModules,
    Top,
    UserCard
  },

  data() {
    return {
      loading: false
    };
  },
  computed: {
    user() {
      return this.$store.state.userProfile;
    },
    isCover() {
      if (this.user) {
        if (!this.user.cover) {
          return false;
        }
        return true;
      }
      return false;
    },
    formattedBio() {
      return formatter.format(this.user.meta.bio);
    }
  },
  methods: {
    fetchUser() {
      this.$store.dispatch("setUserProfile", null);
      this.loading = true;

      user
        .get(this.$route.params.name)
        .then(res => {
          if (res.data.canonical != this.$route.params.name.toLowerCase()) {
            return;
          }
          this.$store.dispatch(
            "title/update",
            "@" + this.$route.params.name + " en Embers"
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
