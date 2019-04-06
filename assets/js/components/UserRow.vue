<template>
  <div class="user-row">
    <avatar :avatar="user.avatar.medium" :status="user.online" :user="user.username"></avatar>
    <router-link
      :to="`/@${user.username}`"
      class="u_name"
      :data-badge="`${user.badges[0]}`"
    >{{ user.username }}</router-link>
    <span class="u_mutual" v-if="user.mutual">Son amigos</span>
    <button
      v-if="user.following"
      @click.prevent="unfollow"
      @mouseover="mouseInUnfollow = true"
      @mouseleave="mouseInUnfollow = false"
      class="button"
      data-button-size="medium"
      data-button-font="big"
      data-button-unmask
      :data-button-dark="!mouseInUnfollow"
      :data-button-important="mouseInUnfollow"
    >
      <template>
        <i v-if="mouseInUnfollow" class="zmdi zmdi-minus-circle"></i>
        <i v-else class="zmdi zmdi-check"></i>
      </template>
      &nbsp;{{mouseInUnfollow ? 'Dejar de seguir' : 'Siguiendo'}}
    </button>
    <button
      v-else
      @click.prevent="follow"
      class="button"
      data-button-size="medium"
      data-button-font="big"
      data-button-unmask
      data-button-success
    >
      <i class="zmdi zmdi-account-add"></i>&nbsp;Seguir
    </button>
  </div>
</template>
<script>
import userAPI from "../api/user";
import avatar from "@/components/Avatar";

export default {
  name: "UserRow",
  props: {
    user: {
      type: Object
    }
  },
  components: { avatar },
  data() {
    return {
      mouseInUnfollow: false,
      mouseInFollow: false
    };
  },
  methods: {
    /**
     * Follows the user
     */
    follow() {
      userAPI.follow(this.user.id).then(user => {
        this.user.following = true;

        if (this.user.mutual) {
          this.$store.dispatch("addMutual", user);
        }
      });
    },

    /**
     * Unfollows the user
     */
    unfollow() {
      userAPI.unfollow(this.user.id).then(user => {
        this.user.following = false;

        if (!this.user.mutual) {
          this.$store.dispatch("removeMutual", user);
        }
      });
    }
  }
};
</script>
