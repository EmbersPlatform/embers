<template>
  <div id="secondary">
    <h3>acerca de mi</h3>
    <p class="bio" v-html="formattedBio"></p>
    <h3>seguidores</h3>
    <avatar
      v-for="follower in followers"
      :key="follower.id"
      :avatar="follower.avatar.small"
      :user="follower.username"
      :data-tip="follower.username"
      data-tip-position="top"
      data-tip-text
    />
  </div>
</template>

<script>
import user from "../../api/user";

import formatter from "@/lib/formatter";
import avatar from "@/components/Avatar";

export default {
  components: { avatar },

  data() {
    return {
      loading: false,
      followers: null
    };
  },
  computed: {
    user() {
      return this.$store.state.userProfile;
    },
    formattedBio() {
      return formatter.format(this.user.bio);
    }
  },
  methods: {
    fetch_followers() {
      this.loading = true;
      user
        .getFollowing({ id: this.user.id })
        .then(res => {
          this.followers = res.friends;
        })
        .finally(() => {
          this.loading = false;
        });
    }
  },
  created() {
    this.fetch_followers();
  }
};
</script>
