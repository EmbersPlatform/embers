<template>
  <li class="nav_ mutuals">
    <ul :class="{'renderbox' : loading}">
      <li v-for="user in orderedMutuals" class="n_item" :key="user.id">
        <router-link :to="`/chat/${user.id}`" active-class="active" class="n_i_wrap">
          <avatar :avatar="user.avatar.small" status="active"></avatar>
          <span class="n_i_w_content u_name">{{ user.username }}</span>
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
        v-if="userMutuals.length === 0 && !loading"
        v-html="formattedNoMutuals"
      ></li>
    </ul>
  </li>
</template>

<script>
import { mapGetters } from "vuex";
import _ from "lodash";

import formatter from "../helpers/formatter";
import avatar from "./avatar";

export default {
  name: "Mutuals",
  components: { avatar },
  props: ["online"],

  /**
   * Computed data
   */
  computed: {
    ...mapGetters(["userMutuals"]),

    /**
     * Text to display when the user's no mutuals
     */
    formattedNoMutuals() {
      return formatter.format("¡Hora de hacer amigos! :metal:");
    },
    orderedMutuals() {
      return _.orderBy(this.mutuals, ["online_at"], ["desc"]);
    }
  },

  /**
   * Component data
   * @returns
   */
  data() {
    return {
      loading: false,
      mutuals: []
    };
  },

  /**
   * Triggered when this component is created
   */
  created() {
    this.$root.$on("updated_presences", presences => {
      this.mutuals = presences;
    });
  }
};
</script>
