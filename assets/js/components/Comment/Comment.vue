<template>
  <div class="comment" :class="{'nsfw': comment.nsfw, 'locked' : locked, remarked: remarked}">
    <header class="header">
      <avatar :avatar="comment.user.avatar.small"></avatar>
      <div class="header-content">
        <h4>
          <router-link
            class="username"
            :to="`/@${comment.user.username}`"
            :data-badge="`${comment.user.badges[0]}`"
          >{{comment.user.username}}</router-link>
          <router-link
            class="comment-time"
            :to="`/post/${comment.id}`"
          >{{ $moment.utc(comment.created_at).local().from() }}:</router-link>
        </h4>
        <p v-if="comment.body" v-html="formattedBody"></p>
        <div v-if="comment.links && comment.links.length && !comment.media.length" class="links">
          <link-item :link="comment.links[0]" />
        </div>
        <div class="multimedia" v-if="comment.media.length">
          <media-zone small :medias="comment.media" :previews="true" @clicked="media_clicked" />
        </div>
        <footer class="actions">
          <ul class="actions-reactions">
            <li
              v-for="(meta, reaction) in comment.reactions"
              @click="react(meta.name)"
              class="reaction"
              :key="reaction.id"
              :reacted="meta.reacted"
            >
              <img :src="`/img/emoji/${meta.name}.svg`" :alt="reaction" class="emoji" />
              {{ meta.total }}
            </li>
          </ul>
          <ul v-if="!no_controls" class="actions-panel">
            <li v-if="comment.nsfw">
              <span @click.prevent="toggleLock">
                <i class="fas fa-pepper-hot emoji"></i>
                <template v-if="locked">&nbsp;Mostrar</template>
                <template v-else>&nbsp;Ocultar</template>
              </span>
            </li>
            <li>
              <span @click.prevent="reply">
                Responder&nbsp;
                <svgicon name="s_reply" class="emoji"></svgicon>
              </span>
            </li>
            <li v-if="!isOwner" class="emoji-pick-list">
              <span
                ref="trg_picker"
                class="picker-switch"
                :class="{'open' : isPicker}"
                data-tip="Elegir una reaccion"
                data-tip-position="bottom"
                data-tip-text
              >
                <svgicon name="s_new-reaction" class="emoji"></svgicon>
              </span>
              <ul v-if="isPicker" data-name="reacciones" ref="picker">
                <li
                  v-for="reaction in reactions"
                  class="reaction"
                  @click="react(reaction)"
                  :key="reaction.id"
                >
                  <img :src="`/img/emoji/${reaction}.svg`" :alt="reaction" class="emoji" />
                </li>
              </ul>
            </li>
          </ul>
        </footer>
      </div>
      <div class="header-options-wrapper">
        <div
          v-if="loggedUser && can('access_mod_tools')"
          class="header-options"
          focusable
          tabindex="-1"
        >
          <span>
            <i class="fas fa-gavel" />
          </span>
          <ul>
            <li v-if="can('update_post')">
              <span v-if="!comment.nsfw" @click.prevent="markAsNsfw">
                <i class="fas fa-pepper-hot"></i>
                Es NSFW
              </span>
              <span v-else @click.prevent="unmarkAsNsfw">
                <i class="fas fa-pepper-hot"></i>
                No es NSFW
              </span>
            </li>
            <li>
              <span @click.prevent="deleteComment(comment)" class="--danger">
                <i class="fas fa-trash-alt"></i>
                Eliminar
              </span>
            </li>
            <li>
              <span @click.prevent="ban_user" class="--danger">
                <i class="fas fa-gavel"></i>
                Suspender usuario
              </span>
            </li>
          </ul>
        </div>
        <div v-if="loggedUser" class="header-options" focusable tabindex="-1">
          <span>
            <svgicon name="n_left-sign"></svgicon>
          </span>
          <ul>
            <li>
              <span @click.prevent="reactionsDetails">
                <i class="far fa-smile"></i>
                Reacciones
              </span>
            </li>
            <li v-if="can('create_report')">
              <span @click.prevent="report_post">
                <i class="far fa-flag"></i>
                Reportar
              </span>
            </li>
            <li v-if="isOwner">
              <span @click.prevent="deleteComment" class="--danger">
                <i class="fas fa-trash-alt"></i>
                Eliminar
              </span>
            </li>
          </ul>
        </div>
      </div>
    </header>
    <template v-if="comment.nesting_level < 2">
      <div class="comments-list replies">
        <div v-if="replies.length > 10" @click="toggle_replies" class="replies-action">
          <template v-if="show_replies">
            <i class="fas fa-chevron-up" /> Ocultar respuestas
          </template>
          <template v-else>
            <i class="fas fa-chevron-down" /> Mostrar respuestas
          </template>
        </div>

        <template v-if="show_replies && !loading_replies">
          <div class="replies-actions">
            <div
              v-if="!last_page && !loading_more_replies"
              @click="load_more_replies"
              class="replies-action"
            >
              <i class="fas fa-level-up-alt" /> Ver mas respuestas
            </div>
          </div>
          <div class="replies-loading" v-if="loading_more_replies">Cargando mas respuestas...</div>
          <comment
            class="is-reply"
            v-for="(c, c_idx) in replies"
            :key="c.id"
            :ref="`reply-${c_idx}`"
            :comment="c"
            @clicked_reply="reply_to"
          />
        </template>
      </div>
      <div v-if="show_replies && show_new_comment_box" class="new-comment reply_box">
        <div class="comment is-reply">
          <div class="comment--toolbox-title">Respondiendo a @{{comment.user.username}}</div>
          <header class="header">
            <avatar v-if="$mq != 'sm'" :avatar="user.avatar.small"></avatar>
            <Toolbox
              flat
              :with_tags="false"
              :parent_id="comment.id"
              :has_overlay="false"
              :with_toolbar="false"
              type="reply"
              autofocus
              ref="comment_box"
              @created="add_reply"
              @closed="cancel_reply"
            ></Toolbox>
          </header>
        </div>
      </div>
    </template>
  </div>
</template>

<script>
import axios from "axios";
import _ from "lodash";
import post from "../../api/post";
import avatar from "@/components/Avatar";
import user from "../../api/user";
import { mapGetters } from "vuex";
import ReactionsModal from "@/components/ReactionsModal/ReactionsModal";
import ReportPostModal from "@/components/Modals/ReportPostModal";
import BanUserModal from "@/components/Modals/BanUserModal";

import MediaZone from "@/components/Media/MediaZone";
import MediaSlides from "@/components/Media/MediaSlides";
import LinkItem from "@/components/Link/Link";

import CommentList from "@/components/Comment/CommentList";
import Toolbox from "@/components/ToolBox/_ToolBox";

import formatter from "@/lib/formatter";
import markdown from "@/lib/markdown/formatter";

export default {
  name: "Comment",
  components: {
    avatar,
    MediaZone,
    MediaSlides,
    LinkItem,
    CommentList,
    Toolbox
  },
  props: {
    comment: { type: Object, required: true },
    postId: { type: String },
    no_controls: { type: Boolean, default: false },
    no_reply_link: { type: Boolean, default: false }
  },
  data() {
    return {
      App: this.$store.state.appData,
      isPicker: false,
      show_media_slides: false,
      locked: false,
      show_replies: true,
      replies: [],
      loading_replies: false,
      loading_more_replies: false,
      last_page: false,
      next: null,
      show_new_comment_box: false
    };
  },
  computed: {
    ...mapGetters(["can", "user"]),
    loggedUser() {
      return this.$store.getters.user;
    },
    /**
     * All supported reactions
     */
    reactions() {
      return "thumbsup thumbsdown grin cry thinking point_up angry tada heart eggplant hot_pepper cookie".split(
        " "
      );
    },
    /**
     * Returns whether the owner of this comment is the authenticated user
     * @return {boolean}
     */
    isOwner() {
      // if(!this.$store.user) return false;
      return this.comment.user.id === this.$store.getters.user.id;
    },

    /**
     * Formats the comment body
     */
    formattedBody() {
      return markdown(this.comment.body, true);
    },
    hasReactions() {
      if (jQuery.isEmptyObject(this.comment.stats.reactions)) {
        return false;
      }
      return true;
    },
    remarked() {
      return (
        this.$route.name == "post" ||
        (this.$route.name == "post_no_user" &&
          this.$route.params.id == this.comment.id)
      );
    }
  },

  methods: {
    toggle_replies() {
      this.show_replies = !this.show_replies;
    },
    reply() {
      this.show_new_comment_box = true;
      this.$emit("clicked_reply", this.comment);
      //this.$root.$emit("reply comment", this.comment.user.username);
    },
    reply_to(comment) {
      this.show_new_comment_box = true;
      this.$nextTick(() => {
        console.log(this.$refs.comment_box);
        this.$refs.comment_box.reply_to(comment.user.username);
      });
    },
    cancel_reply() {
      this.show_new_comment_box = false;
      //this.$root.$emit("reply comment", this.comment.user.username);
    },
    add_reply(reply) {
      this.replies.push(reply);
      this.comment.stats.replies++;
    },
    async load_replies() {
      this.loading_replies = true;
      let { data: res } = await axios(
        `/api/v1/posts/${this.comment.id}/replies`,
        { params: { order: "desc", limit: 2 } }
      );
      res.items = res.items.reverse();
      if (!this.replies) {
        this.replies = res.items;
      } else {
        this.replies = [...res.items, ...this.replies];
      }
      this.loading_replies = false;
      this.last_page = res.last_page;
      this.next = res.next;
    },
    async load_more_replies() {
      this.loading_more_replies = true;
      let { data: res } = await axios(
        `/api/v1/posts/${this.comment.id}/replies`,
        { params: { order: "desc", limit: 10, before: this.next } }
      );
      res.items = res.items.reverse();
      this.replies = _.sortBy([...res.items, ...this.replies], "inserted_at");
      this.loading_more_replies = false;
      this.last_page = res.last_page;
      this.next = res.next;
      this.$nextTick(() => {
        this.$refs["reply-0"][0].$el.scrollIntoView({ behavior: "smooth" });
      });
    },
    toggleLock() {
      this.locked = !this.locked;
    },
    /**
     * Deletes this comment
     * @param commentObject Comment object
     */
    deleteComment() {
      this.$modal.show("dialog", {
        title: "¿Seguro que quieres eliminar este comentario?",
        text: "Si lo haces se perderá para siempre. ¡Eso es mucho tiempo!",
        buttons: [
          {
            title: "Cancelar",
            class: "button"
          },
          {
            title: "Eliminar",
            default: true,
            class: "button danger",
            handler: () => {
              post
                .deletePost(this.comment.id)
                .then(() => this.$emit("deleted", this.comment));
              this.$modal.hide("dialog");
            }
          }
        ],
        adaptive: true
      });
    },

    /**
     * Deletes user avatar
     */
    deleteAvatar() {
      user.settings.deleteAvatar(this.comment.user.id).then(() => {
        this.$notify({
          group: "top",
          text: "El avatar ha sido eliminado.",
          type: "success"
        });
      });
    },

    /**
     * Removes the user cover image
     */
    deleteCover() {
      user.settings.deleteCover(this.comment.user.id).then(() => {
        this.$notify({
          group: "top",
          text: "La portada de perfil ha sido eliminada.",
          type: "success"
        });
      });
    },

    /**
     * Kicks user
     */
    kick() {
      this.$modal.show("dialog", {
        title: "¿De verdad quieres expulsar a este usuario?",
        buttons: [
          {
            title: "Cancelar",
            class: "button"
          },
          {
            title: "Expulsar",
            default: true,
            class: "button danger",
            handler: () => {
              user.kick(this.comment.user.id).then(() => {
                this.$notify({
                  group: "top",
                  text: "El usuario ha sido expulsado.",
                  type: "success"
                });
                this.comment.user.active = false;
              });
              this.$modal.hide("dialog");
            }
          }
        ],
        adaptive: true
      });
    },

    /**
     * Unkicks a user
     */
    unkick() {
      this.$modal.show("dialog", {
        title: "¿Quieres rehabilitar a este usuario?",
        buttons: [
          {
            title: "Cancelar",
            class: "button"
          },
          {
            title: "Rehabilitar",
            default: true,
            class: "button danger",
            handler: () => {
              user.unkick(this.comment.user.id).then(() => {
                this.$notify({
                  group: "top",
                  text: "El usuario ha sido rehabilitado.",
                  type: "success"
                });
                this.comment.user.active = true;
              });
              this.$modal.hide("dialog");
            }
          }
        ],
        adaptive: true
      });
    },

    /**
     * Show the detailed reactions
     */
    reactionsDetails() {
      this.$modal.show(
        ReactionsModal,
        { post_id: this.comment.id },
        {
          adaptive: true,
          height: "auto"
        }
      );
    },

    /**
     * Adds a reaction to this comment
     * @todo Implement multiple reactions
     */
    // react(reaction) {
    // 	if(this.isOwner) return;
    // 	comment.addReaction(this.comment.id, reaction).then(res => {
    // 		this.comment.reacted = true;
    // 		this.comment.stats = res;
    // 	});
    // },
    react(reaction) {
      this.isPicker = false;
      if (this.isOwner) {
        return;
      }
      if (
        this.comment.reactions[reaction] &&
        this.comment.reactions[reaction].reacted
      ) {
        post.deleteReaction(this.comment.id, reaction).then(res => {
          this.comment.reacted = false;
          this.comment.reactions = res.reactions;
        });
      } else {
        post.addReaction(this.comment.id, reaction).then(res => {
          this.comment.reacted = true;
          this.comment.reactions = res.reactions;
        });
      }
    },
    media_clicked(id) {
      const index = this.comment.media.findIndex(m => m.id == id);
      this.$store.dispatch("media_slides/open", {
        medias: this.comment.media,
        index: index
      });
    },
    /**
     * Marks the post as Not Safe For Work
     */
    async markAsNsfw() {
      let tags = this.comment.tags.map(x => x.name);
      tags.push("nsfw");
      let { data: res } = await axios.post(
        "/api/v1/moderation/post/update_tags",
        {
          post_id: this.comment.id,
          tag_names: tags
        }
      );
      this.comment.nsfw = true;
      this.comment.tags = res.tags;
      this.show =
        !this.comment.nsfw ||
        this.$store.getters.settings.content_nsfw !== "hide";
      this.locked =
        this.comment.nsfw &&
        this.$store.getters.settings.content_nsfw === "ask";
    },
    /**
     * Unmarks the post as Not Safe For Work
     */
    async unmarkAsNsfw() {
      let tags = this.comment.tags.map(x => x.name).filter(x => x != "nsfw");
      let { data: res } = await axios.post(
        "/api/v1/moderation/post/update_tags",
        {
          post_id: this.comment.id,
          tag_names: tags
        }
      );
      this.comment.nsfw = false;
      this.comment.tags = res.tags;
      this.show =
        !this.comment.nsfw ||
        this.$store.getters.settings.content_nsfw !== "hide";
      this.locked =
        this.comment.nsfw &&
        this.$store.getters.settings.content_nsfw === "ask";
    },
    report_post() {
      this.$modal.show(
        ReportPostModal,
        { post_id: this.comment.id },
        { height: "auto", adaptive: true, maxWidth: 400, scrollable: true }
      );
    },
    ban_user() {
      this.$modal.show(
        BanUserModal,
        { user_id: this.comment.user.id },
        { height: "auto", adaptive: true, maxWidth: 400, scrollable: true }
      );
    }
  },
  created() {
    this.locked =
      this.comment.nsfw && this.$store.getters.settings.content_nsfw === "ask";
  },
  mounted() {
    this.load_replies();
    $(this.$refs.trg_picker).on({
      "click tap": () => {
        this.isPicker = true;
      }
    });
    $(window).on("click tap", e => {
      let isChild = !!$(e.target).parents("span.picker-switch").length;
      let isMenu = $(this.$refs.picker).is(e.target);
      let isTrigger = $(this.$refs.trg_picker).is(e.target.closest("span"));
      if (!isChild && !isMenu && !isTrigger) {
        // If click is issued outside user menu and outside menu's trigger
        this.isPicker = false;
      }
    });
  }
};
</script>

<style lang="scss">
@import "~@/../sass/base/_variables.scss";
.comment {
  &.remarked > .header {
    background-color: transparentize($narrojo, 0.9);
    box-shadow: 0 0 5px rgba(235, 61, 45, 0.2) !important;
  }
  &.is-reply {
    .avatar {
      width: 32px;
      height: 32px;
    }
  }
  .links {
    padding: 0 20px;

    .link-item__oembed {
      padding: 0;
      transform: none;
    }
    .link-item__details {
      display: none;
    }
  }
  .comment-time {
    font-weight: 300 !important;
    color: #ffffff50 !important;
  }
}
.replies-actions {
  position: sticky;
  top: 0;
  z-index: 2;
  background: $dark;
}
.replies-action {
  padding: 5px 10px;
  font-weight: 500;
  cursor: pointer;
  &:hover {
    color: #fff;
  }

  .fa-level-up-alt {
    transform: rotate(90deg);
  }
}
.replies-loading {
  opacity: 0.7;
  text-align: center;
  padding: 5px 10px;
}
.comment--toolbox-title {
  padding: 20px 10px;
  color: #999;
}
</style>
