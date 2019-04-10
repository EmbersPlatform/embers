<template>
  <div id="wrapper" data-layout-type="column">
    <div class="block" data-layout-type="column">
      <h2>Usuarios seguidos</h2>
    </div>
    <div
      class="block"
      data-layout-type="column"
      :class="{'renderbox': loading}"
      :data-renderbox-message="'Cargando...'"
      v-infinite-scroll="loadMore"
      :infinite-scroll-disabled="infiniteScrollStill"
    >
      <UserRow v-for="user in followingUsers" :key="user.id" :user="user"></UserRow>
    </div>
  </div>
</template>

<script>
import userAPI from "../../api/user";
import UserRow from "../../components/UserRow";

export default {
  name: "FollowingUsers",
  components: { UserRow },
  data() {
    return {
      followingUsers: null,
      oldestId: null,
      last_page: false,
      loading: true,
      previousScrollPosition: 0
    };
  },
  computed: {
    infiniteScrollStill() {
      return this.loading || this.last_page;
    }
  },
  methods: {
    getPreviousScrollPosition() {
      this.previousScrollPosition = $(window).scrollTop();
    },
    fetchUsers() {
      this.loading = true;
      userAPI
        .getFollowed()
        .then(res => {
          if (this._inactive) {
            return;
          }
          this.followingUsers = res.items;

          this.followingUsers.map(user => {
            user.following = true;
            return user;
          });

          if (res.items.length) {
            this.oldestId = res.items[res.items.length - 1].id;
          }
          this.last_page = res.last_page;
        })
        .finally(() => {
          this.loading = false;
        });
    },

    loadMore() {
      if (this.infiniteScrollStill) {
        return;
      }
      this.loading = true;
      this.getPreviousScrollPosition();
      userAPI
        .getFollowed({ after: this.oldestId })
        .then(res => {
          if (this._inactive) {
            return;
          }
          if (res.items.length) {
            this.followingUsers.push(...res.items);
            this.oldestId = res.items[res.items.length - 1].id;
          }
          this.last_page = res.last_page;
        })
        .finally(() => {
          if (this._inactive) {
            return;
          }
          this.$nextTick(() => {
            window.scrollTo(0, this.previousScrollPosition);
          });
          this.loading = false;
        });
    }
  },

  created() {
    this.fetchUsers();
  }
};
</script>
