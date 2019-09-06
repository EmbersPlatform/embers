<template>
  <div id="content" data-layout-type="single-column">
    <Feed v-if="user" :name="`user/${user.id}?comments=true`"></Feed>
  </div>
</template>

<script>
import axios from "axios";
import feed from "@/api/feed";
import ToolBox from "@/components/ToolBox/_ToolBox";
import Feed from "@/components/Feed";
import user from "@/api/user";

import formatter from "@/lib/formatter";
import { concat_post } from "@/lib/posts";
import { mapState } from "vuex";

export default {
  components: {
    ToolBox,
    Feed
  },
  computed: {
    ...mapState({ user: state => state.userProfile }),
    isSelfProfile() {
      if (!this.$store.getters.user) {
        return false;
      }
      return this.$route.params.name === this.$store.getters.user.name;
    }
  }
};
</script>
