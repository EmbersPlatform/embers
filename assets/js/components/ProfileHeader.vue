<template>
  <div class="profile-header">
    <div class="profile-cover">
      <img :src="user.cover" class="profile-cover-image" ref="cover_img" />
      <div class="profile-user">
        <avatar :avatar="user.avatar.medium"></avatar>
        <div class="profile-username">
          <span class="at">@</span>
          <span class="username">{{user.username}}</span>
        </div>
      </div>
      <div class="profile-stats">
        <div class="stat">
          <span class="stat-value">{{user.stats.posts}}</span>
          <span class="stat-name">Posts</span>
        </div>
        <div class="stat">
          <span class="stat-value">{{user.stats.comments}}</span>
          <span class="stat-name">Comentarios</span>
        </div>
        <div class="stat">
          <span class="stat-value">{{user.stats.followers}}</span>
          <span class="stat-name">Seguidores</span>
        </div>
        <div class="stat">
          <span class="stat-value">{{user.stats.friends}}</span>
          <span class="stat-name">Siguiendo</span>
        </div>
      </div>
    </div>
    <div class="profile-details">
      <div class="profile-actions">
        <template v-if="!isAuthUser">
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
        </template>
        <template v-if="isAuthUser">
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
        </template>
        <template v-if="can('ban_user')">
          <button
            @click.prevent="ban_user"
            class="button"
            data-button-size="medium"
            data-button-font="big"
            data-button-unmask
            data-button-dark
          >
            <i class="fas fa-gavel"></i>
          </button>
        </template>
        <template v-if="!isAuthUser">
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
        </template>
      </div>
      <div class="profile-bio" v-html="formattedBio"></div>
      <div class="profile-following" v-if="!no_following">
        <router-link :to="`/@${user.username}`" v-for="(user, index) in following" :key="index">
          <avatar :avatar="user.avatar.small" />
        </router-link>
        <router-link
          :to="`/@${user.username}/following`"
          v-if="user.stats.friends > following.length"
          class="more-friends"
        >Y {{ user.stats.friends - following.length }} seguidos más</router-link>
      </div>
    </div>
  </div>
</template>

<script>
import user from "@/api/user";
import { mapGetters } from "vuex";
import BanUserModal from "@/components/Modals/BanUserModal";
import Avatar from "@/components/Avatar";
import markdown from "@/lib/markdown/formatter";

export default {
  name: "ProfileHeader",
  components: { Avatar },
  props: {
    user: {
      type: Object,
      required: true
    },
    no_following: {
      type: Boolean,
      default: false
    }
  },
  data: () => ({
    following: [],
    mouseInUnfollow: false
  }),
  computed: {
    ...mapGetters(["can"]),
    isAuthUser() {
      if (!this.$store.getters.user) return false;
      return this.user.id === this.$store.getters.user.id;
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
      return markdown(this.user.bio);
    }
  },
  methods: {
    follow() {
      user.follow(this.user.id).then(user => {
        this.user.following = true;
      });
    },
    unfollow() {
      user.unfollow(this.user.id).then(user => {
        this.user.following = false;
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
    },
    ban_user() {
      this.$modal.show(
        BanUserModal,
        { user_id: this.user.id },
        { height: "auto", adaptive: true, maxWidth: 400, scrollable: true }
      );
    },
    fetch_following() {
      user.getFollowing({ id: this.user.id, limit: 10 }).then(res => {
        this.following = res.items.slice(0, 10);
      });
    }
  },
  mounted() {
    if (!this.no_following) this.fetch_following();
  }
};
</script>

<style lang="scss" scoped>
.profile-cover {
  width: 960px;
  max-width: 100%;
  height: 320px;
  padding: 0;
  margin: 0 auto;
  border-radius: 10px;
  box-sizing: border-box;
  display: flex;
  flex-direction: column;
  color: #fff;
  overflow: hidden;
}

.profile-cover-image {
  width: 960px;
  height: 320px;
  position: absolute;
  left: 50%;
  transform: translateX(-50%);
}

.profile-user {
  flex-grow: 1;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;

  .avatar {
    width: 100px;
    height: 100px;
  }
  .profile-username {
    span {
      font-size: 3em;
      text-shadow: 0 1px 2px #000, 0 1px 3px #000;
    }
    .at {
      color: #999;
    }
    .username {
      font-weight: 400;
    }
  }
}
.profile-stats {
  display: flex;
  justify-content: space-around;
  background: linear-gradient(transparent, #000);
  padding: 20px;
  .stat {
    text-align: center;
    display: flex;
    flex-direction: column;
    span {
      text-shadow: 0 1px 2px #000, 0 1px 3px #000;
    }
    .stat-value {
      font-size: 2em;
      font-weight: 400;
    }
  }
}
.profile-actions {
  display: flex;
  flex-direction: row;
  justify-content: center;
  padding: 10px;
}
.profile-following {
  display: flex;
  flex-direction: row;
  justify-content: center;
  flex-wrap: wrap;
  align-items: center;
  .avatar {
    width: 48px;
    height: 48px;
    margin: 5px;
    border: 4px solid #00000033;
    border-radius: 50%;
  }
  .more-friends {
    color: #999;
    padding: 5px;
    font-weight: 500;
  }
}

.button {
  color: #fff;
  margin: 0 5px;
  padding: 10px;
  display: block;
  height: auto !important;
  border: 3px solid rgba(0, 0, 0, 0.14);
}
.profile-bio {
  text-align: center;
  padding: 10px;

  p,
  p > * {
    font-size: 1.25rem;
  }
  a {
    color: #fff;
    font-weight: 400;
  }
}
</style>
