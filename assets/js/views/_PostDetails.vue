<template>
  <div id="board">
    <template v-if="!loading && post">
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
            <p class="loading-comments" v-if="loading_context">Cargando..</p>
            <Card v-if="post_context" :post="post_context" @deleted="postDeleted"/>
            <Card v-if="is_post" :post="post" @deleted="postDeleted"></Card>
            <Comment v-if="is_comment" :comment="post" @deleted="postDeleted" no_reply_link></Comment>
            <Comment
              v-if="comment_context"
              :comment="comment_context"
              @deleted="postDeleted"
              no_reply_link
            ></Comment>
            <p class="loading-comments" v-if="loadingComments">Cargando comentarios...</p>
            <CommentList
              :comments="comments"
              :loading="loadingComments"
              :bottomComments="bottomComments"
              :lastPage="lastPage"
              :postId="id"
              :class="{replies: is_comment || is_reply}"
              @loadMore="loadComments"
              @comment_deleted="comment_deleted"
            ></CommentList>
            <div class="new-comment" :class="{reply_box: is_comment || is_reply}">
              <div class="comment">
                <header class="header">
                  <avatar v-if="$mq != 'sm'" :avatar="user.avatar.small"></avatar>
                  <Toolbox
                    v-if="user"
                    flat
                    :with_tags="false"
                    :parent_id="reply_to_id"
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
import Comment from "@/components/Comment/Comment";
import Toolbox from "@/components/ToolBox/_ToolBox";
import Avatar from "@/components/Avatar";

export default {
  components: {
    Card,
    Comment,
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
      lastPage: true,
      post_context: null,
      comment_context: null,
      loading_context: false
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
    }),
    has_context() {
      return this.post.nesting_level > 0;
    },
    is_post() {
      return this.post.nesting_level == 0;
    },
    is_comment() {
      return this.post.nesting_level == 1;
    },
    is_reply() {
      return this.post.nesting_level == 2;
    },
    reply_to_id() {
      if (this.post.nesting_level == 2) {
        return this.post.in_reply_to;
      } else {
        return this.post.id;
      }
    }
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
          this.$router.replace({
            name: "post",
            params: { username: this.post.user.username, id: this.post.id }
          });
          return;
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
        this.loadComments();
        this.load_context();
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

      let id = this.post.id;
      if (this.is_reply) id = this.post.in_reply_to;

      comment
        .get(
          id,
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
    },
    async load_context() {
      if (!this.has_context) return;
      this.loading_context = true;
      const res = await post.get(this.post.in_reply_to);
      if (this.is_comment) {
        this.post_context = res;
      } else {
        this.comment_context = res;
        const root = await post.get(res.in_reply_to);
        this.post_context = root;
      }
      this.loading_context = false;
    }
  },

  /**
   * Initializes the view
   */
  mounted() {
    this.getPost();
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
.comment {
  margin-bottom: 0 !important;
}
.replies {
  border-left: 3px solid #eb3d2d44;
  margin-left: 50px;

  .comment {
    padding-top: 20px;
  }
}

.reply_box {
  margin-left: 50px;
}
</style>

