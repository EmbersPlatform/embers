<template>
  <div id="wrapper" data-layout-type="column">
    <div class="block" data-layout-type="column">
      <h2>Bloqueos</h2>
    </div>
    <div
      class="block"
      data-layout-type="column"
      :class="{'renderbox': showRenderbox}"
      :data-renderbox-message="renderboxMessage"
    >
      <div class="user-row" v-for="user in users" :key="user.id">
        <router-link
          :to="`/@${user.username}`"
          class="u_name"
        >{{ user.username }}</router-link>
        <button
          v-if="user.blocked"
          @click.prevent="unblock(user)"
          class="button"
          data-button-size="medium"
          data-button-font="big"
          data-button-unmask
          data-button-dark
        >
          <i class="zmdi zmdi-check"></i>
          &nbsp;Desbloquear
        </button>
        <button
          v-else
          @click.prevent="block(user)"
          class="button"
          data-button-size="medium"
          data-button-font="big"
          data-button-unmask
          data-button-important
        >
          <i class="zmdi zmdi-minus-circle"></i>&nbsp;Bloquear
        </button>
      </div>
    </div>
  </div>
</template>

<script>
import _ from "lodash";
import userAPI from "../../api/user";

export default {
  name: "Blocks",
  data() {
    return {
      users: null,
      loading: true
    };
  },
  computed: {
    showRenderbox() {
      return this.loading || this.users.length === 0;
    },
    renderboxMessage() {
      if (this.loading) return "Cargando...";
      if (this.users.length === 0) return "No has bloqueado a nadie. ¡Hurra!";
    }
  },
  methods: {
    block(user) {
      userAPI.block(user.id).then(res => {
        let index = _.findIndex(this.users, { id: user.id });
        _.set(this.users[index], "blocked", true);
      });
    },
    unblock(user) {
      userAPI.unblock(user.id).then(res => {
        let index = _.findIndex(this.users, { id: user.id });
        _.set(this.users[index], "blocked", false);
      });
    },
    fetchUsers() {
      this.loading = true;
      userAPI
        .getBlocked()
        .then(res => {
          console.log(res);
          if (this._inactive) {
            return;
          }
          this.users = res.items;
        })
        .finally(() => {
          this.loading = false;
        });
    }
  },

  created() {
    this.fetchUsers();
  }
};
</script>
