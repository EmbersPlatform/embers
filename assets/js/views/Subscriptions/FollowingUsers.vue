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
      followingUsers: [],
      next: null,
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
          this.next = res.next;
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
        .getFollowed({ after: this.next })
        .then(res => {
          if (this._inactive) {
            return;
          }
          res.items = res.items.map(x => {
            x.following = true;
            return x;
          });
          this.followingUsers.push(...res.items);
          this.next = res.next;
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
