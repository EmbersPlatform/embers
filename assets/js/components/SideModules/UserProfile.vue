<template>
	<div id="secondary">
		<h3>acerca de mi</h3>
		<p class="bio" v-html="formattedBio"></p>
		<template v-if="$store.getters.user">
			<h3>seguidores</h3>
			<p>
				<avatar v-for="follower in followers" :key="follower.id" :avatar="follower.avatar.small" :user="follower.name":data-tip="follower.name" data-tip-position="top" data-tip-text></avatar>
			</p>
		</template>
	</div>
</template>

<script>
import user from "../../api/user";

import formatter from "../../helpers/formatter";
import avatar from "../avatar";

export default {
  components: { avatar },

  data() {
    return {
      loading: false,
      followers: null,
      followed: null
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
    fetchUser() {
      user.getFollowing({ id: this.user.id }).then(res => {
        this.followers = res.items.slice(0, 12);
      });
    }
  },
  created() {
    this.fetchUser();
  }
};
</script>
