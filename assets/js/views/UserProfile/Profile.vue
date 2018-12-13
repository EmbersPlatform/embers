<template>
  <div id="content" data-layout-type="single-column">
    <ToolBox v-if="isSelfProfile"></ToolBox>
    <Feed v-if="user" :name="`user/${user.id}`"></Feed>
  </div>
</template>

<script>
import feed from "../../api/feed";
import ToolBox from "../../components/ToolBox/_ToolBox";
import Feed from "../../components/Feed";
import user from "../../api/user";

import formatter from "@/lib/formatter";

export default {
  components: {
    ToolBox,
    Feed
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
    isSelfProfile() {
      if (!this.$store.getters.user) {
        return false;
      }
      return this.$route.params.name === this.$store.getters.user.name;
    }
  },
  methods: {
    fetchUser() {
      this.$store.dispatch("cleanFeedPosts");
      this.$store.dispatch(
        "updateTitle",
        "@" + this.$route.params.name + " en Embers"
      );
    }
  },
  watch: {
    $route: "fetchUser"
  },

  /**
   * Triggered when a component instance is created
   */
  created() {
    this.fetchUser();
  },

  /**
   * Triggered before this component instance is destroyed
   */
  beforeDestroy() {
    this.$store.dispatch("cleanFeedPosts");
  }
};
</script>
