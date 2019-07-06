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
      <header class="header" v-if="!no_header">
        <avatar
          v-if="isShared"
          :avatar="post.user.avatar.small"
          :user="post.user.username"
          :isShared="isShared"
          :sharers="post.sharers"
        ></avatar>
        <avatar v-else :avatar="post.user.avatar.small" :user="post.user.username"></avatar>
        <div class="header-content">
          <h4>
            <template v-if="isShared">
              <template v-if="post.sharers.length == 2">
                <router-link
                  class="username"
                  :to="`/@${post.sharers[post.sharers.length-1].username}`"
                >{{ post.sharers[post.sharers.length-1].username }}</router-link>
                <p>&nbsp;y&nbsp;</p>
              </template>
              <router-link
                class="username"
                :to="`/@${post.sharers[0].username}`"
                :data-badge="`${post.sharers[0].badges[0]}`"
              >{{ post.sharers[0].username }}</router-link>
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
            </template>
          </h4>
          <router-link
            class="card-date"
            :to="`/post/${post.id}`"
          >{{ $moment.utc(post.created_at).local().from() }}</router-link>
        </div>
        <div
          v-if="tools && loggedUser && can('access_mod_tools')"
          class="header-options"
          focusable
          tabindex="-1"
        >
          <span>
            <i class="fas fa-gavel" />
          </span>
          <ul>
            <li v-if="can('update_post')">
              <span v-if="!post.nsfw" @click.prevent="markAsNsfw">
                <i class="fas fa-pepper-hot"></i>
                Es NSFW
              </span>
              <span v-else @click.prevent="unmarkAsNsfw">
                <i class="fas fa-pepper-hot"></i>
                No es NSFW
              </span>
            </li>
            <li>
              <span @click.prevent="deletePost(post)" class="--danger">
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
        <div v-if="tools && loggedUser" class="header-options" focusable tabindex="-1">
          <span
            @click="toggleFav"
            :data-tip="(post.faved) ? 'Quitar de mis favoritos' : 'Agregar a favoritos'"
            data-tip-position="bottom"
            data-tip-text
          >
            <i v-if="!post.faved" class="far fa-star" />
            <i v-else class="fas fa-star" />
          </span>
        </div>
        <div v-if="tools && loggedUser" class="header-options" focusable tabindex="-1">
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
            <li v-if="removable">
              <span @click.prevent="hide_post">
                <i class="far fa-eye-slash"></i>
                Ocultar
              </span>
            </li>
            <li v-if="can('create_report')">
              <span @click.prevent="report_post">
                <i class="far fa-flag"></i>
                Reportar
              </span>
            </li>
            <li v-if="isOwner">
              <span @click.prevent="deletePost(post)" class="--danger">
                <i class="fas fa-trash-alt"></i>
                Eliminar
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
        <div v-if="post.links && post.links.length && !post.media.length" class="links">
          <link-item :link="post.links[0]" @clicked="media_clicked" />
        </div>
        <div class="multimedia" v-if="post.media.length">
          <media-zone
            :medias="post.media"
            :previews="true"
            @clicked="media_clicked"
            :little="size == 'little'"
          />
        </div>
        <template v-if="with_related && post.related_to">
          <card
            :no_header="isShared"
            :footer="false"
            :post="post.related_to"
            :tools="false"
            class="related"
          />
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
          <Tag v-for="(tag, index) in post.tags" :key="index" :tag="tag" />
        </div>
      </section>
    </div>
    <footer
      v-if="footer && (!isPostView || isPostView && (!isOwner || hasReactions || post.stats.replies > 0 || post.stats.shares > 0))"
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
          <img :src="`/img/emoji/${meta.name}.svg`" :alt="meta.name" class="emoji" />
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
              <img :src="`/img/emoji/${reaction}.svg`" :alt="reaction" class="emoji" />
            </li>
          </ul>
        </li>
        <li v-if="!isPostView">
          <router-link
            :to="`/post/${post.id}`"
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
import axios from "axios";

import VideoEmbed from "./VideoEmbed";
import LinkEmbed from "./LinkEmbed";
import AudioPlayer from "./AudioPlayer";
import MediaZone from "@/components/Media/MediaZone";
import Tag from "@/components/Tag/Tag";
import LinkItem from "@/components/Link/Link";

import formatter from "@/lib/formatter";
import avatar from "@/components/Avatar";
import markdown from "@/lib/markdown/formatter";

import ReactionsModal from "../ReactionsModal/ReactionsModal";
import ReportPostModal from "@/components/Modals/ReportPostModal";
import BanUserModal from "@/components/Modals/BanUserModal";

import EventBus from "@/lib/event_bus";

import { mapGetters } from "vuex";

export default {
  name: "card",
  props: {
    post: {
      type: Object,
      required: true
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
    },
    footer: {
      type: Boolean,
      default: true
    },
    tools: {
      type: Boolean,
      default: true
    },
    with_related: {
      type: Boolean,
      default: true
    },
    no_header: {
      type: Boolean,
      default: false
    },
    removable: {
      type: Boolean,
      default: false
    }
  },
  components: {
    VideoEmbed,
    LinkEmbed,
    AudioPlayer,
    MediaZone,
    avatar,
    Tag,
    LinkItem
  },
  computed: {
    ...mapGetters(["can"]),
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
      return "thumbsup thumbsdown grin cry thinking point_up angry tada heart eggplant hot_pepper cookie".split(
        " "
      );
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

    isShared() {
      return !!this.post.sharers;
    },

    /**
     * Formats post body
     */
    formattedBody() {
      return markdown(this.post.body);
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
      if (this.post.sharers.length > 1) {
        if (this.post.sharers.length > 2) {
          var usuarios = "@" + this.post.sharers[0].username;
          for (var i = 1; i < this.post.sharers.length; i++) {
            if (i == this.post.sharers.length - 1) {
              usuarios += " y @" + this.post.sharers[i].username;
            } else {
              usuarios += ", @" + this.post.sharers[i].username;
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
      EventBus.$emit("show_new_post_modal", { related: this.post });
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
      const has_reacted =
        _.find(this.post.reactions, x => {
          return x.name == reaction && x.reacted;
        }) != undefined;
      this.isPicker = false;
      if (this.isOwner) {
        return;
      }
      if (has_reacted) {
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
      this.$modal.show(
        ReactionsModal,
        { post_id: this.post.id },
        {
          adaptive: true,
          height: "auto"
        }
      );
    },

    toggleFav() {
      if (!this.post.faved) {
        post.favorite(this.post.id).then(res => {
          this.post.faved = true;
          this.post.stats = res;
        });
      } else {
        post.unfavorite(this.post.id).then(res => {
          this.post.faved = false;
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
    async markAsNsfw() {
      let tags = this.post.tags.map(x => x.name);
      tags.push("nsfw");
      let { data: res } = await axios.post(
        "/api/v1/moderation/post/update_tags",
        {
          post_id: this.post.id,
          tag_names: tags
        }
      );
      this.post.nsfw = true;
      this.post.tags = res.tags;
      this.show =
        !this.post.nsfw || this.$store.getters.settings.content_nsfw !== "hide";
      this.locked =
        this.post.nsfw && this.$store.getters.settings.content_nsfw === "ask";
    },
    /**
     * Unmarks the post as Not Safe For Work
     */
    async unmarkAsNsfw() {
      let tags = this.post.tags.map(x => x.name).filter(x => x != "nsfw");
      let { data: res } = await axios.post(
        "/api/v1/moderation/post/update_tags",
        {
          post_id: this.post.id,
          tag_names: tags
        }
      );
      this.post.nsfw = false;
      this.post.tags = res.tags;
      this.show =
        !this.post.nsfw || this.$store.getters.settings.content_nsfw !== "hide";
      this.locked =
        this.post.nsfw && this.$store.getters.settings.content_nsfw === "ask";
    },
    media_clicked(id) {
      let medias = this.post.media;
      let index = this.post.media.findIndex(m => m.id == id);
      if (!medias.length) {
        const link = this.post.links[0];
        medias = [
          {
            id: link.id,
            url: link.url,
            type: "image",
            metadata: {
              preview_url: link.url
            },
            timestamp: 1
          }
        ];
        index = 0;
      }
      this.$store.dispatch("media_slides/open", {
        medias: medias,
        index: index
      });
    },
    report_post() {
      this.$modal.show(
        ReportPostModal,
        { post_id: this.post.id },
        { height: "auto", adaptive: true, maxWidth: 400, scrollable: true }
      );
    },
    ban_user() {
      this.$modal.show(
        BanUserModal,
        { user_id: this.post.user.id },
        { height: "auto", adaptive: true, maxWidth: 400, scrollable: true }
      );
    },
    hide_post() {
      let ids = [];
      if (!this.post.activities_ids) {
        ids = [this.post.id];
      } else {
        ids = this.post.activities_ids;
      }
      ids.forEach(async post_id => {
        axios.delete(`/api/v1/feed/activity/${post_id}`);
      });
      this.$emit("deleted");
    },
    init_intersector() {
      const options = {};
      this.observer = new IntersectionObserver(([entry]) => {
        if (entry && entry.isIntersecting) {
          this.$emit("intersect", this.$el);
        }
        if (entry && !entry.isIntersecting) {
          this.$emit("leave");
        }
      }, options);

      this.observer.observe(this.$el);
    }
  },

  /**
   * Component data
   */
  data() {
    return {
      App: this.$store.state.appData,
      show:
        !this.post.nsfw || this.$store.getters.settings.content_nsfw !== "hide",
      locked:
        this.post.nsfw && this.$store.getters.settings.content_nsfw === "ask",
      unfolded: false,
      imageTooLarge: false,
      imageSize: null,
      showImage: true,
      attachmentError: false,
      isPicker: false,
      user,
      show_media_slides: false,
      clicked_media_index: 0
    };
  },
  destroyed() {
    this.observer.disconnect();
  },
  mounted() {
    this.init_intersector();
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
.card {
  .links {
    padding: 0 20px;
  }

  .header-options {
    & > span:hover {
      i {
        color: #ffffffb3;
      }
    }
    i {
      color: #ffffff4d;
    }
  }
}
.emoji-pick-list {
  .ul {
    z-index: 1;
  }
}
</style>
