<template>
  <div class="comment" :class="{'nsfw': comment.nsfw, 'locked' : locked}">
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
        <div v-if="comment.links && comment.links.length && !comment.media.length" class="links">
          <link-item :link="comment.links[0]"/>
        </div>
        <div class="multimedia" v-if="comment.media.length">
          <media-zone small :medias="comment.media" :previews="true" @clicked="media_clicked"/>
        </div>
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
                  <img :src="`/img/emoji/${reaction}.svg`" :alt="reaction" class="emoji">
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
            <i class="fas fa-gavel"/>
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
            <li v-if="hasReactions">
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
    <media-slides
      v-if="show_media_slides"
      :medias="comment.media"
      :index="clicked_media_index"
      @closed="show_media_slides = false"
    ></media-slides>
  </div>
</template>

<script>
import axios from "axios";
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

import formatter from "@/lib/formatter";

export default {
  components: { avatar, MediaZone, MediaSlides, LinkItem },
  props: ["comment", "postId"],
  computed: {
    ...mapGetters(["can"]),
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
    },
    media_clicked(id) {
      this.clicked_media_index = this.comment.media.findIndex(m => m.id == id);
      this.show_media_slides = true;
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
    media_clicked(id) {
      this.clicked_media_index = this.comment.media.findIndex(m => m.id == id);
      this.show_media_slides = true;
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

  /**
   * Component data
   * @returns {object}
   */
  data() {
    return {
      App: this.$store.state.appData,
      isPicker: false,
      show_media_slides: false,
      locked: false,
      user
    };
  },
  created() {
    this.locked =
      this.comment.nsfw && this.$store.getters.settings.content_nsfw === "ask";
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

<style lang="scss">
.comment {
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
}
</style>
