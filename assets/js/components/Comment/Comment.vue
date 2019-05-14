<template>
  <div class="comment">
    <header class="header">
      <avatar :avatar="comment.user.avatar.small"></avatar>
      <div class="header-content">
        <h4>
          <router-link
            class="username"
            :to="`/@${comment.user.username}`"
            :data-badge="`${comment.user.badges[0]}`"
          >{{comment.user.username}}</router-link>
          <p>comento {{ $moment.utc(comment.created_at).local().from() }}:</p>
        </h4>
        <p v-if="comment.body" v-html="formattedBody"></p>
        <footer class="actions">
          <ul class="actions-reactions">
            <li
              v-for="(meta, reaction) in comment.stats.reactions"
              @click="react(reaction)"
              class="reaction"
              :key="reaction.id"
              :reacted="meta.reacted"
            >
              <img :src="`/img/emoji/${reaction}.svg`" :alt="reaction" class="emoji">
              {{ meta.total }}
            </li>
          </ul>
          <ul v-if="loggedUser" class="actions-panel">
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
                  <img :src="`/img/emoji/${reaction}.svg`" :alt="reaction" class="emoji">
                </li>
              </ul>
            </li>
          </ul>
        </footer>
      </div>
      <div class="header-options" focusable tabindex="-1">
        <span>
          <svgicon name="n_left-sign"></svgicon>
        </span>
        <ul>
          <li v-if="hasReactions">
            <span @click.prevent="reactionsDetails">
              <i class="far fa-smile"></i>
              Reacciones
            </span>
          </li>
          <template v-if="!isOwner">
            <li>
              <span v-if="!comment.user.following" @click.prevent="follow">
                <i class="fas fa-user-plus"></i>
                Seguir
              </span>
              <span v-else @click.prevent="unfollow">
                <i class="fas fa-minus-circle"></i>
                Dejar de seguir
              </span>
            </li>
            <template v-if="user.can('user.kick')">
              <li v-if="comment.user.active">
                <span @click.prevent="kick">
                  <i class="fas fa-pause-circle"></i>
                  Expulsar
                </span>
              </li>
              <li v-else>
                <span @click.prevent="unkick">
                  <i class="fas fa-play-circle"></i>
                  Rehabilitar
                </span>
              </li>
            </template>
          </template>
          <li v-if="isOwner || user.can('post.delete_third_party')">
            <span @click.prevent="deleteComment(comment)">
              <i class="fas fa-trash-alt"></i>
              Eliminar
            </span>
          </li>
          <li v-if="user.can('user.avatar.delete_third_party')">
            <span @click.prevent="deleteAvatar">
              <i class="fas fa-user-circle"></i>
              Quitar avatar
            </span>
          </li>
          <li v-if="user.can('user.cover.delete_third_party')">
            <span @click.prevent="deleteCover">
              <i class="far address-book"></i>
              Quitar portada
            </span>
          </li>
        </ul>
      </div>
    </header>
  </div>
</template>

<script>
import comment from "../../api/comment";
import avatar from "@/components/Avatar";
import user from "../../api/user";
import { mapGetters } from "vuex";
import ReactionsModal from "../ReactionsModal/ReactionsModal";

import formatter from "@/lib/formatter";

export default {
  components: { avatar },
  props: ["comment", "postId"],
  computed: {
    loggedUser() {
      return this.$store.getters.user;
    },
    /**
     * All supported reactions
     */
    reactions() {
      return "thumbsup thumbsdown grin cry open_mouth angry heart eggplant fire".split(
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
      return formatter.format(this.comment.body, true);
    },
    hasReactions() {
      if (jQuery.isEmptyObject(this.comment.stats.reactions)) {
        return false;
      }
      return true;
    }
  },

  methods: {
    reply() {
      this.$root.$emit("reply comment", this.comment.user.username);
    },
    /**
     * Deletes this comment
     * @param commentObject Comment object
     */
    deleteComment(commentObject) {
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
              comment
                .deleteComment(this.postId, commentObject.id)
                .then(() => this.$emit("deleted", commentObject));
              this.$modal.hide("dialog");
            }
          }
        ],
        adaptive: true
      });
    },

    /**
     * Follows the comment owner
     */
    follow() {
      user.follow(this.comment.user.id).then(user => {
        this.comment.user.following = true;

        if (user.mutual) {
          this.$store.dispatch("addMutual", user);
        }
      });
    },

    /**
     * Unfollows the comment owner
     */
    unfollow() {
      user.unfollow(this.comment.user.id).then(user => {
        this.comment.user.following = false;

        if (!user.mutual) {
          this.$store.dispatch("removeMutual", user);
        }
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
      comment.getReactionsDetails(this.comment.id).then(res => {
        this.$modal.show(
          ReactionsModal,
          { reactions: res },
          {
            adaptive: true,
            height: "auto"
          }
        );
      });
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
        this.comment.stats.reactions[reaction] &&
        this.comment.stats.reactions[reaction].reacted
      ) {
        comment.deleteReaction(this.comment.id, reaction).then(res => {
          this.comment.reacted = false;
          this.comment.stats = res;
        });
      } else {
        comment.addReaction(this.comment.id, reaction).then(res => {
          this.comment.reacted = true;
          this.comment.stats = res;
        });
      }
    }
  },

  /**
   * Component data
   * @returns {object}
   */
  data() {
    return {
      App: this.$store.state.appData,
      isPicker: false,
      user
    };
  },
  mounted() {
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
