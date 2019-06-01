<template>
  <div id="board">
    <template v-if="!loading">
      <div id="heading" class="user">
        <template>
          <hr v-if="post.user.cover" :style="'background-image: url('+post.user.cover+');'">
          <hr v-else style="background-image: url(/cover/default.jpg);">
        </template>
        <Top></Top>
        <UserCard :user="post.user" type="wide"></UserCard>
      </div>
      <div id="wrapper">
        <div id="content" data-layout-type="single-column">
          <div id="post" v-if="post" :class="{container: !user}">
            <Card :post="post" @deleted="postDeleted"></Card>
            <p class="loading-comments" v-if="loadingComments">Cargando comentarios...</p>
            <CommentList
              :comments="comments"
              :loading="loadingComments"
              :bottomComments="bottomComments"
              :lastPage="lastPage"
              :postId="id"
              @loadMore="loadComments"
              @comment_deleted="comment_deleted"
            ></CommentList>
            <div class="new-comment">
              <div class="comment">
                <header class="header">
                  <avatar :avatar="$store.getters.user.avatar.small"></avatar>
                  <Toolbox
                    v-if="user"
                    flat
                    :with_tags="false"
                    :parent_id="id"
                    :has_overlay="false"
                    always_open
                    type="comment"
                    @created="addComment"
                  ></Toolbox>
                </header>
              </div>
            </div>
          </div>
        </div>
      </div>
    </template>
  </div>
</template>

<script>
import Top from "@/components/Top";
import UserCard from "@/components/UserCard";

import formatter from "@/lib/formatter";
import post from "@/api/post";
import comment from "@/api/comment";
import { mapGetters } from "vuex";

import Card from "@/components/Card/_Card";
import CommentList from "@/components/Comment/CommentList";
import Toolbox from "@/components/ToolBox/_ToolBox";
import Avatar from "@/components/Avatar";

export default {
  components: {
    Card,
    CommentList,
    Toolbox,
    Top,
    UserCard,
    Avatar
  },

  /**
   * Component data
   */
  data() {
    return {
      post: null,
      comments: [],
      bottomComments: [],
      loading: false,
      loadingComments: false,
      lastPage: true
    };
  },

  /**
   * Precomputed data
   */
  computed: {
    /**
     * Decimal post ID
     */
    id() {
      return this.$route.params.id;
    },
    ...mapGetters({
      user: "user"
    })
  },

  methods: {
    /**
     * Retrieves the post
     */
    async getPost() {
      this.loading = true;
      try {
        let res = await post.get(this.id);
        this.post = res;
        if (
          this.$route.name == "post_no_user" ||
          this.$route.params.username !== this.post.user.username
        ) {
          this.$router.push({
            name: "post",
            params: { username: this.post.user.username, id: this.post.id }
          });
        }
        if (res.body) {
          this.$store.dispatch(
            "title/update",
            `${res.body.substring(0, 20)} · @${res.user.username} en Embers`
          );
        } else {
          this.$store.dispatch(
            "title/update",
            `Post de @${res.user.username} en Embers`
          );
        }

        if (res.stats.comments > 0) {
          this.loadComments();
        }
      } catch (e) {
        this.$router.push("/404");
      }
      this.loading = false;
    },

    /**
     * Retrieves the post's comments
     */
    loadComments() {
      this.loadingComments = true;

      comment
        .get(
          this.id,
          this.bottomComments.length ? this.bottomComments[0].id : null,
          this.comments.length
            ? this.comments[this.comments.length - 1].id
            : null
        )
        .then(res => {
          this.comments = this.comments.concat(res.items);
          this.lastPage = res.last_page;
        })
        .finally(() => (this.loadingComments = false));
    },

    /**
     * Adds a comment to the post view
     *
     * @param      {object}  comment  The comment object
     */
    addComment(comment) {
      this.bottomComments.push(comment);
    },

    /**
     * Post is deleted
     */
    postDeleted() {
      this.$router.push("/");
      this.$notify({
        group: "top",
        text: "Post eliminado exitosamente.",
        type: "success"
      });
    },
    comment_deleted(comment) {
      console.log("filtering comment:", comment);
      this.comments = this.comments.filter(x => x.id != comment.id);
      this.bottomComments = this.bottomComments.filter(x => x.id != comment.id);
    }
  },

  /**
   * Initializes the view
   */
  created() {
    this.getPost();
    this.loadComments();
  },

  watch: {
    $route: function() {
      this.comments = [];
      this.bottomComments = [];
      this.lastPage = this.loadingComments = this.loading = false;

      this.getPost();
    }
  }
};
</script>

<style lang="scss">
.loading-comments {
  text-align: center;
  color: #ffffff70;
}
</style>

