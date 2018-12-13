<template>
  <article
    v-if="show"
    class="card"
    :class="{'nsfw': post.nsfw, 'locked' : locked, 'new': post.new}"
    :data-card-size="size"
    focusable
    tabindex="-1"
  >
    <div class="card-flags" v-if="post.nsfw">
      <div v-if="post.nsfw" class="flag nsfw" :class="{'isLocked' : locked}">
        <p>
          <strong
            data-tip="Contiene material explicito."
            data-tip-position="left"
            data-tip-text
          >NSFW:</strong>
        </p>
        <button
          data-button-font="little"
          data-button-size="little"
          class="button"
          @click.prevent="toggleLock"
        >{{(!this.locked) ? 'ocultar' : 'ver'}}</button>
      </div>
    </div>
    <div class="card-wrapper" :class="{'locked' : locked, 'is-picker': isPicker}">
      <header class="header">
        <avatar
          :avatar="post.user.avatar.small"
          :user="post.user.username"
          :isShared="isShared"
          :sharers="sharers"
        ></avatar>
        <div class="header-content">
          <h4>
            <template v-if="isShared">
              <template v-if="sharers.length == 2">
                <router-link
                  class="username"
                  :to="`/@${sharers[sharers.length-1].username}`"
                  :data-badge="`${sharers[sharers.length-1].badges[0]}`"
                >{{ sharers[sharers.length-1].username }}</router-link>
                <p>&nbsp;y&nbsp;</p>
              </template>
              <router-link
                class="username"
                :to="`/@${sharers[0].username}`"
                :data-badge="`${sharers[0].badges[0]}`"
              >{{ sharers[0].username }}</router-link>
              <p v-html="s_message"></p>
              <router-link
                class="username"
                :to="`/@${post.user.username}`"
                :data-badge="`${post.user.badges[0]}`"
              >{{post.user.username}}</router-link>
              <p>:</p>
            </template>
            <template v-else>
              <router-link
                class="username"
                :to="`/@${post.user.username}`"
                :data-badge="`${post.user.badges[0]}`"
              >{{post.user.username}}</router-link>
              <p>compartio:</p>
            </template>
          </h4>
          <small>{{ $moment.utc(post.created_at).local().from() }}</small>
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
            <template v-if="!isOwner">
              <li>
                <span v-if="!post.user.following" @click.prevent="follow">
                  <i class="fas fa-user-plus"></i>
                  Seguir
                </span>
                <span v-else @click.prevent="unfollow">
                  <i class="fas fa-minus-circle"></i>
                  Dejar de seguir
                </span>
              </li>
              <template v-if="user.can('user.kick')">
                <li v-if="post.user.active">
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
              <span @click.prevent="deletePost(post)">
                <i class="fas fa-trash-alt"></i>
                Eliminar
              </span>
            </li>
            <li v-if="user.can('post.delete_third_party')">
              <span v-if="!post.nsfw" @click.prevent="markAsNsfw">
                <i class="fas flag-checkered"></i>
                Es NSFW
              </span>
              <span v-else @click.prevent="unmarkAsNsfw">
                <i class="far fa-flag"></i>
                No es NSFW
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
      <section class="card-wrapper-content" :class="{'big-text': (post.body && bigTextBody)}">
        <p v-if="post.body" v-html="formattedBody" :class="{folded: (bodyTooLong && !unfolded)}"></p>
        <div v-if="post.body && bodyTooLong && !unfolded" class="controls">
          <button
            v-if="size != 'little'"
            @click.prevent="unfold"
            class="button"
            data-button-size="medium"
            data-button-font="medium"
            data-button-normal-text
          >Leer todo</button>
          <router-link
            v-else
            :to="post.url"
            class="button"
            data-button-size="medium"
            data-button-font="medium"
            data-button-normal-text
          >Ir al post</router-link>
        </div>
        <template v-if="post.media">
          <div class="multimedia">
            <template v-if="post.media.length < 3">
              <div class="row">
                <div class="media image" v-for="(media, index) in post.media" :key="index">
                  <img :src="`/media/image/${media.url}`">
                </div>
              </div>
            </template>
            <template v-else>
              <div class="media image">
                <img :src="`/media/image/${post.media[0].url}`">
              </div>
              <div class="row">
                <div
                  class="media image"
                  v-for="(media, index) in post.media"
                  v-if="index > 0"
                  :key="index"
                >
                  <img :src="`/media/image/${media.url}`">
                </div>
              </div>
            </template>
          </div>
        </template>
        <template v-if="post.attachment">
          <VideoEmbed :video="post.attachment" v-if="post.attachment.type === 'video'"></VideoEmbed>
          <LinkEmbed :link="post.attachment" :post="post" v-if="post.attachment.type === 'link'"></LinkEmbed>
          <AudioPlayer
            :url="post.attachment.url"
            :avatar="post.user.avatar.small"
            v-if="post.attachment.type === 'audio'"
          ></AudioPlayer>
          <p v-if="attachmentError">Hubo un error al cargar el archivo adjunto :c</p>
        </template>
        <div class="card-wrapper-content-tags" v-if="post.tags && post.tags.length">
          <router-link
            :to="`/search/in:${tag}`"
            class="tag"
            v-for="tag in post.tags"
            :key="tag"
          >#{{ tag }}</router-link>
        </div>
      </section>
    </div>
    <footer
      v-if="!isPostView || isPostView && (!isOwner || hasReactions || post.stats.replies > 0 || post.stats.shares > 0)"
      class="actions"
    >
      <ul class="actions-reactions">
        <li
          v-for="(meta, reaction) in post.reactions"
          @click="react(meta.name)"
          class="reaction"
          :key="reaction.id"
          :reacted="meta.reacted"
        >
          <img :src="`/img/emoji/${meta.name}.svg`" :alt="meta.name" class="emoji">
          {{ meta.total }}
        </li>
      </ul>
      <ul class="actions-panel">
        <li v-if="loggedUser && !isOwner" class="emoji-pick-list">
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
        <li v-if="loggedUser">
          <span
            @click="toggleFav"
            :data-tip="(post.isFaved) ? 'Quitar de mis favoritos' : 'Agregar a favoritos'"
            data-tip-position="bottom"
            data-tip-text
          >
            {{(post.stats.favorites > 0) ? post.stats.favorites+'&nbsp;' : ''}}
            <svgicon v-if="!post.isFaved" name="s_sponsored" class="emoji"></svgicon>
            <svgicon v-if="post.isFaved" name="s_sponsored_filled" class="emoji"></svgicon>
          </span>
        </li>
        <li v-if="!isPostView">
          <router-link
            :to="`/@${post.user.username}/${post.id}`"
            data-tip="Ver comentarios"
            data-tip-position="bottom"
            data-tip-text
          >
            {{(post.stats.replies > 0) ? post.stats.replies+'&nbsp;' : ''}}
            <svgicon name="s_comment" class="emoji"></svgicon>
          </router-link>
        </li>
        <template v-else>
          <li v-if="post.stats.replies > 0 && (!isOwner || isOwner)">
            <span data-tip="Cantidad de comentarios" data-tip-position="bottom" data-tip-text>
              {{(post.stats.replies > 0) ? post.stats.replies+'&nbsp;' : ''}}
              <svgicon name="s_comment" class="emoji"></svgicon>
            </span>
          </li>
        </template>
        <li v-if="loggedUser && (!isOwner || isOwner && post.stats.shares > 0)">
          <span
            @click="share"
            :data-tip="(isOwner) ? 'No puedes compartir algo tuyo' : 'Compartir post'"
            data-tip-position="bottom"
            data-tip-text
          >
            {{(post.stats.shares > 0) ? post.stats.shares+'&nbsp;' : ''}}
            <svgicon name="s_share" class="emoji"></svgicon>
          </span>
        </li>
      </ul>
    </footer>
  </article>
</template>

<script>
import post from "../../api/post";
import user from "../../api/user";
import attachment from "../../api/attachment";

import VideoEmbed from "./VideoEmbed";
import LinkEmbed from "./LinkEmbed";
import AudioPlayer from "./AudioPlayer";

import formatter from "@/lib/formatter";
import avatar from "@/components/Avatar";

import ReactionsModal from "../ReactionsModal/ReactionsModal";

import { mapGetters } from "vuex";

export default {
  props: {
    post: {
      type: Object,
      required: true
    },
    isShared: {
      type: Boolean,
      default: false,
      required: false
    },
    sharers: {
      type: Array,
      required: false
    },
    showThumbnail: {
      type: Boolean,
      default: false,
      required: false
    },
    size: {
      type: String,
      default: "medium",
      required: false
    }
  },
  components: {
    VideoEmbed,
    LinkEmbed,
    AudioPlayer,
    avatar
  },
  computed: {
    isPostView() {
      return this.$route.path === this.post.url;
    },
    loggedUser() {
      return this.$store.getters.user;
    },
    /**
     * All supported reactions
     */
    reactions() {
      return [
        "thumbsup",
        "thumbsdown",
        "tada",
        "cry",
        "heart",
        "eggplant",
        "grin",
        "angry",
        "open_mouth",
        "fire"
      ];
    },

    /**
     * Whether the current user is the post owner
     */
    isOwner() {
      if (!this.$store.getters.user) {
        return false;
      }
      return this.post.user.id === this.$store.getters.user.id;
    },

    /**
     * Formats post body
     */
    formattedBody() {
      return formatter.format(this.post.body);
    },

    /**
     * Check whether the body has too many lines
     */
    bodyTooLong() {
      if (!this.isPostView) {
        if (!this.post.body) {
          return false;
        }
        return this.post.body.split(/[\r\n]/).length > 8;
      }
      return false;
    },
    /**
     * Big text body
     */
    bigTextBody() {
      return (
        this.post.body.length <= 85 &&
        !/\r|\n/.exec(this.post.body) &&
        !this.post.attachment
      );
    },
    /**
     * Gets image thumbnail URL
     */
    thumbnailUrl() {
      if (this.post.attachment.url.indexOf(".gif") !== -1) {
        return this.post.attachment.url;
      }
      return `//rsz.io/${this.post.attachment.url.replace(
        /(^\w+:|^)\/\//,
        ""
      )}?mode=max&width=${Math.round(window.innerWidth / 1.4)}`;
    },
    //shared message
    s_message() {
      if (this.sharers.length > 1) {
        if (this.sharers.length > 2) {
          var usuarios = "@" + this.sharers[0].username;
          for (var i = 1; i < this.sharers.length; i++) {
            if (i == this.sharers.length - 1) {
              usuarios += " y @" + this.sharers[i].username;
            } else {
              usuarios += ", @" + this.sharers[i].username;
            }
          }
          return (
            'y <strong data-tip="' +
            usuarios +
            ' compartieron esta publicacion" data-tip-position="bottom" data-tip-text>varios mas</strong> compartieron via'
          );
        } else {
          return "compartieron via";
        }
      }
      return "compartio via";
    },
    hasReactions() {
      if (jQuery.isEmptyObject(this.post.reactions)) {
        return false;
      }
      return true;
    }
  },

  methods: {
    /**
     * Unfolds the post
     */
    unfold() {
      this.unfolded = true;
    },
    toggleLock() {
      this.locked = !this.locked;
    },
    /**
     * Shares the post with subscribers
     */
    share() {
      if (!this.loggedUser || this.isOwner || this.post.alreadyShared) {
        return;
      }
      this.$modal.show("dialog", {
        text: "¿Compartir este post con tus seguidores?",
        buttons: [
          {
            title: "Nah",
            class: "button"
          },
          {
            title: "Oh, sí",
            default: true,
            class: "button success",
            handler: () => {
              post.share(this.post.id).then(() => {
                this.$notify({
                  group: "top",
                  text: "El post fue compartido :)",
                  type: "success"
                });
              });
              this.$modal.hide("dialog");
            }
          }
        ],
        adaptive: true
      });
    },
    /**
     * Delete this post
     * @param post Post object
     */
    deletePost(postObject) {
      this.$modal.show("dialog", {
        title: "¿Seguro que quieres eliminar este post?",
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
              post.deletePost(postObject.id).then(() => {
                this.$store.dispatch("removeFeedPost", postObject);
                this.$emit("deleted");
              });
              this.$modal.hide("dialog");
            }
          }
        ],
        adaptive: true
      });
    },

    /**
     * Follows the post owner
     */
    follow() {
      user.follow(this.post.user.id).then(user => {
        this.post.user.following = true;
        if (user.mutual) {
          this.$store.dispatch("addMutual", user);
        }
      });
    },

    /**
     * Unfollows the post owner
     */
    unfollow() {
      user.unfollow(this.post.user.id).then(user => {
        this.post.user.following = false;
        if (!user.mutual) {
          this.$store.dispatch("removeMutual", user);
        }
      });
    },

    /**
     * Adds a reaction to this post
     * @todo Implement multiple reactions
     */
    react(reaction) {
      this.isPicker = false;
      if (this.isOwner) {
        return;
      }
      if (
        this.post.reactions[reaction] &&
        this.post.reactions[reaction].reacted
      ) {
        post.deleteReaction(this.post.id, reaction).then(res => {
          this.post.reacted = true;
          this.post.reactions = res.reactions;
        });
      } else {
        post.addReaction(this.post.id, reaction).then(res => {
          this.post.reacted = true;
          this.post.reactions = res.reactions;
        });
      }
    },

    /**
     * Show the detailed reactions
     */
    reactionsDetails() {
      post.getReactionsDetails(this.post.id).then(res => {
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

    toggleFav() {
      if (!this.post.isFaved) {
        post.favorite(this.post.id).then(res => {
          this.post.isFaved = true;
          this.post.stats = res;
        });
      } else {
        post.unfavorite(this.post.id).then(res => {
          this.post.isFaved = false;
          this.post.stats = res;
        });
      }
    },

    /**
     * Removes the user avatar
     */
    deleteAvatar() {
      user.settings.deleteAvatar(this.post.user.id).then(() => {
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
      user.settings.deleteCover(this.post.user.id).then(() => {
        this.$notify({
          group: "top",
          text: "La portada ha sido eliminada.",
          type: "success"
        });
      });
    },

    /**
     * Kicks user
     */
    kick() {
      this.$modal.show("dialog", {
        text: "¿De verdad quieres expulsar a este usuario?",
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
              user.kick(this.post.user.id).then(() => {
                this.$notify({
                  group: "top",
                  text: "El usuario ha sido expulsado.",
                  type: "success"
                });
                this.post.user.active = false;
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
        text: "¿Quieres rehabilitar a este usuario?",
        buttons: [
          {
            title: "Cancelar",
            class: "button"
          },
          {
            title: "Rehabilitar",
            default: true,
            class: "button success",
            handler: () => {
              user.unkick(this.post.user.id).then(() => {
                this.$notify({
                  group: "top",
                  text: "El usuario ha sido rehabilitado",
                  type: "success"
                });
                this.post.user.active = true;
              });
              this.$modal.hide("dialog");
            }
          }
        ],
        adaptive: true
      });
    },

    /**
     * Marks the post as Not Safe For Work
     */
    markAsNsfw() {
      post.nsfw(this.post.id, true).then(res => {
        this.post.nsfw = true;
        this.show =
          !this.post.nsfw ||
          this.$store.getters.settings.content_nsfw !== "hide";
        this.locked =
          this.post.nsfw && this.$store.getters.settings.content_nsfw === "ask";
      });
    },
    /**
     * Unmarks the post as Not Safe For Work
     */
    unmarkAsNsfw() {
      post.nsfw(this.post.id, false).then(res => {
        this.post.nsfw = false;
        this.show =
          !this.post.nsfw ||
          this.$store.getters.settings.content_nsfw !== "hide";
        this.locked =
          this.post.nsfw && this.$store.getters.settings.content_nsfw === "ask";
        if (this.locked) {
          this.lock();
        }
        if (!this.locked) {
          this.unlock();
        }
      });
    }
  },

  /**
   * Component data
   */
  data() {
    return {
      App: this.$store.state.appData,
      show: false,
      locked: false,
      unfolded: false,
      imageTooLarge: false,
      imageSize: null,
      showImage: true,
      attachmentError: false,
      isPicker: false,
      user
    };
  },

  /**
   * Triggered when an instance of this component gets created
   */
  created() {
    this.show =
      !this.post.nsfw || this.$store.getters.settings.content_nsfw !== "hide";
    this.locked =
      this.post.nsfw && this.$store.getters.settings.content_nsfw === "ask";
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
