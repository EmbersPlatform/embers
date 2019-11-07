<template>
  <div id="board">
    <template>
      <div id="heading" class="user">
        <Top></Top>
      </div>
      <div id="wrapper">
        <div id="content" data-layout-type="single-column">
          <div id="post" :class="{container: !user}">
            <p class="loading-comments" v-if="loading_context">Cargando..</p>
            <Card v-if="post" :post="post" @deleted="postDeleted"></Card>
            <div class="post-disabled" v-if="post_disabled">El post no se encuentra disponible.</div>
            <template v-if="featured_comment">
              <div class="featured-comment" id="featured_comment">
                <div
                  class="featured-comment--title"
                >Comentario de @{{featured_comment.user.username}}</div>
                <Comment :comment="featured_comment" @deleted="postDeleted" no_reply_link />
              </div>
            </template>
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
            <div
              v-if="user && post && !post_disabled"
              class="new-comment"
              :class="{reply_box: is_comment || is_reply}"
            >
              <div class="comment">
                <header class="header">
                  <avatar v-if="$mq != 'sm'" :avatar="user.avatar.small"></avatar>
                  <Toolbox
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
import postAPI from "@/api/post";
import comment from "@/api/comment";
import { mapGetters } from "vuex";

import Card from "@/components/Card/_Card";
import CommentList from "@/components/Comment/CommentList";
import Comment from "@/components/Comment/Comment";
import Toolbox from "@/components/ToolBox/_ToolBox";
import Avatar from "@/components/Avatar";
import ProfileHeader from "@/components/ProfileHeader";

export default {
  components: {
    Card,
    Comment,
    CommentList,
    Toolbox,
    Top,
    UserCard,
    Avatar,
    ProfileHeader
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
      loading_context: false,
      featured_comment: null,
      post_disabled: false
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
      if (!this.post) return;
      return this.post.nesting_level > 0;
    },
    is_post() {
      if (!this.post) return;
      return this.post.nesting_level == 0;
    },
    is_comment() {
      if (!this.post) return;
      return this.post.nesting_level == 1;
    },
    is_reply() {
      if (!this.post) return;
      return this.post.nesting_level == 2;
    },
    reply_to_id() {
      if (!this.post) return;
      if (this.post.nesting_level == 2) {
        return this.post.in_reply_to;
      } else {
        return this.post.id;
      }
    }
  },

  methods: {
    async get_post() {
      this.loading = true;
      let post = await postAPI.get(this.id);
      if (post === "post_disabled") {
        this.post_disabled = true;
        return;
      }
      if (post.nesting_level == 0) {
        this.post = post;
      }
      if (post.nesting_level == 1) {
        this.featured_comment = post;
        this.post = await postAPI.get(post.in_reply_to);
      }
      if (post.nesting_level == 2) {
        this.featured_comment = await postAPI.get(post.in_reply_to);
        this.post = await postAPI.get(this.featured_comment.in_reply_to);
      }
      if (post.nesting_level > 0) {
        this.$nextTick(() => {
          document
            .getElementById("featured_comment")
            .scrollIntoView({ behavior: "smooth" });
        });
      }
      this.loadComments();
      this.loading = false;
    },

    /**
     * Retrieves the post's comments
     */
    loadComments() {
      this.loadingComments = true;
      let id = this.post.id;

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
      const res = await postAPI.get(this.post.in_reply_to);
      if (this.is_comment) {
        this.post_context = res;
      } else {
        this.comment_context = res;
        const root = await postAPI.get(res.in_reply_to);
        this.post_context = root;
      }
      this.loading_context = false;
    }
  },

  /**
   * Initializes the view
   */
  mounted() {
    this.get_post();
  },

  watch: {
    $route: function() {
      this.comments = [];
      this.bottomComments = [];
      this.lastPage = this.loadingComments = this.loading = false;

      this.get_post();
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
.featured-comment {
  border-bottom: 2px solid #0003;
  padding-bottom: 20px;
}
.featured-comment--title {
  font-size: 1.5em;
  font-weight: 500;
}

.post-disabled {
  border: 1px solid #fff2;
  padding: 1em;
  border-radius: 2px;
  background: #0002;
  font-size: 1.2em;
}
</style>

