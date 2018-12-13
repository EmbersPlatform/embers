<template>
  <div v-if="user" class="profile" :data-layout-type="type">
    <template v-if="type == 'compact'">
      <hr v-if="user.cover" :style="'background-image: url('+user.cover+');'">
      <hr v-else style="background-image: url(/cover/default.jpg);">
    </template>
    <div class="profile-info">
      <h2>
        <template v-if="type == 'compact'">
          <avatar :avatar="user.avatar.medium" :status="user.online" :user="user.name"></avatar>
          <span>@
            <router-link
              :to="`/@${user.username}`"
              class="u_name"
              :data-badge="`${user.badges[0]}`"
            >{{ user.username }}</router-link>en Embers
          </span>
        </template>
        <template v-else>
          <avatar :avatar="user.avatar.medium" :status="user.online"></avatar>
          <span>
            @
            <span class="u_name" :data-badge="`${user.badges[0]}`">{{ user.username }}</span> en Embers
          </span>
        </template>
      </h2>
    </div>
    <div class="profile-stats">
      <ul v-if="$store.getters.user">
        <li v-if="!isAuthUser">
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
              <i v-if="mouseInUnfollow" class="fas fa-minus-circle"></i>
              <i v-else class="fas fa-check"></i>
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
            <i class="fas fa-user-plus"></i>&nbsp;Seguir
          </button>
        </li>
        <li v-if="isAuthUser">
          <router-link
            to="/settings/appearance"
            class="button"
            data-button-size="medium"
            data-button-font="big"
            data-button-unmask
            data-button-dark
          >
            <i class="fas fa-cog"></i>&nbsp;Cambiar apariencia
          </router-link>
        </li>
        <li v-if="!isAuthUser">
          <button
            v-if="user.blocked"
            @click.prevent="unblock"
            class="button"
            data-button-size="medium"
            data-button-font="big"
            data-button-unmask
            data-button-dark
          >
            <i class="zmdi zmdi-check"></i>&nbsp;Desbloquear
          </button>
          <button
            v-else
            class="button"
            @click.prevent="block"
            data-button-size="medium"
            data-button-font="big"
            data-button-unmask
            data-button-dark
          >
            <i class="zmdi zmdi-minus-circle"></i>&nbsp;Bloquear
          </button>
        </li>
      </ul>
      <ul>
        <li>
          <span>{{ user.stats.posts }}</span>
          <span class="title">Posts</span>
        </li>

        <li>
          <span>{{ user.stats.followers }}</span>
          <span class="title">Seguidores</span>
        </li>

        <li>
          <span>{{ user.stats.friends }}</span>
          <span class="title">Siguiendo</span>
        </li>
      </ul>
    </div>
  </div>
</template>
<script>
import user from "../api/user";
import formatter from "@/lib/formatter";
import avatar from "@/components/Avatar";

export default {
  components: {
    avatar
  },
  props: {
    user: {
      type: Object
    },
    type: {
      type: String
    }
  },
  data() {
    return {
      mouseInUnfollow: false,
      mouseInFollow: false
    };
  },
  computed: {
    isAuthUser() {
      if (!this.$store.getters.user) return false;
      return this.user.id === this.$store.getters.user.id;
    },
    formattedBio() {
      return formatter.format(this.user.bio);
    }
  },
  methods: {
    /**
     * Follows the user
     */
    follow() {
      user.follow(this.user.id).then(user => {
        this.user.following = true;

        if (user.mutual) {
          this.$store.dispatch("addMutual", user);
        }
      });
    },

    /**
     * Unfollows the user
     */
    unfollow() {
      user.unfollow(this.user.id).then(user => {
        this.user.following = false;

        if (!user.mutual) {
          this.$store.dispatch("removeMutual", user);
        }
      });
    },

    block() {
      user.block(this.user.id).then(res => {
        this.user.blocked = true;
      });
    },
    unblock() {
      user.unblock(this.user.id).then(res => {
        this.user.blocked = false;
      });
    }
  }
};
</script>
