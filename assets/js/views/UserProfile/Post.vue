<template>
  <div id="content" data-layout-type="single-column">
    <div id="post" v-if="post" :class="{container: !user}">
      <Card :post="post" @deleted="postDeleted"></Card>
      <CommentList
        :comments="comments"
        :loading="loadingComments"
        :bottomComments="bottomComments"
        :lastPage="lastPage"
        :postId="id"
        @loadMore="loadComments"
        @comment_deleted="comment_deleted"
      ></CommentList>
      <NewCommentBox v-if="user" :postId="id" @created="addComment"></NewCommentBox>
    </div>
  </div>
</template>

<script>
import post from "../../api/post";
import comment from "../../api/comment";
import { mapGetters } from "vuex";

import Card from "../../components/Card/_Card";
import CommentList from "../../components/Comment/CommentList";
import NewCommentBox from "../../components/Comment/NewCommentBox";

export default {
  components: {
    Card,
    CommentList,
    NewCommentBox
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
