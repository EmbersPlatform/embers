<template>
  <li class="nav_ mutuals">
    <ul :class="{'renderbox' : loading}">
      <li v-for="user in ordered_friends" class="n_item" :key="user.id">
        <router-link :to="`/@${user.username}`" active-class="active" class="n_i_wrap">
          <avatar :avatar="user.avatar.small" status="active"></avatar>
          <span class="n_i_w_content u_name">{{ user.username }}</span>
          <router-link tag="i" class="fas fa-paper-plane" :to="`/chat/${user.username}`"></router-link>
        </router-link>
      </li>
      <!-- <li class="n_item">
				<button id="new_friend" class="n_i_wrap">
					<avatar svg="s_plus"></avatar>
					<span class="n_i_w_content">añadir amigo</span>
				</button>
      </li>-->
      <li
        key="no-results"
        class="no-results"
        v-if="online_friends.length === 0 && !loading"
        v-html="formatted_no_friends"
      ></li>
    </ul>
  </li>
</template>

<script>
import { mapGetters, mapState } from "vuex";
import _ from "lodash";

import formatter from "@/lib/formatter";
import avatar from "@/components/Avatar";

export default {
  name: "Mutuals",
  components: { avatar },
  props: ["online"],

  /**
   * Computed data
   */
  computed: {
    ...mapState("chat", ["online_friends"]),

    /**
     * Text to display when the user's no mutuals
     */
    formatted_no_friends() {
      return formatter.format("No tienes amigos conectados.");
    },
    ordered_friends() {
      return _.orderBy(this.online_friends, ["online_at"], ["desc"]);
    }
  },

  /**
   * Component data
   * @returns
   */
  data() {
    return {
      loading: false
    };
  }
};
</script>

<style lang="scss">
@import "~@/../sass/base/_variables.scss";
.mutuals {
  .n_i_wrap {
    display: flex;
    color: #fff;

    .u_name {
      flex-grow: 1;
    }
    .avatar,
    i {
      flex-shrink: 0;
    }

    i {
      display: block;
      visibility: hidden;
      padding: 5px;
      border-radius: 3px;

      &:hover {
        background: #ffffff33;
      }

      @media #{$query-mobile} {
        visibility: visible;
      }
    }

    &:hover i {
      visibility: visible;
    }
  }
}
</style>

