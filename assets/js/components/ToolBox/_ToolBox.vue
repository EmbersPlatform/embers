<template>
  <div
    class="toolbox"
    :class="{'tool-box-open': canShowEditor, 'renderbox': status.loading, flat: flat}"
    v-shortkey="['esc']"
    @shortkey="close"
    tabindex="-1"
  >
    <div class="toolbox__overlay" v-if="has_overlay && show_overlay" @click="close"></div>
    <div class="toolbox__container">
      <template>
        <Editor
          :type="type"
          @update="updateBody"
          @paste="handlePaste"
          @focus="openEditor"
          :with_toolbar="with_toolbar"
          :class="{'compressed': !canShowEditor, 'big-text': bigTextBody}"
          data-editor-style="toolbox"
          ref="editor"
          :autofocus="autofocus"
        ></Editor>
        <div v-if="with_tags" class="tags-wrapper tool" :class="{'compact': !canShowEditor}">
          <input type="text" placeholder="Tags separados por espacios" v-model="post.tags" />
        </div>

        <div class="tool" v-if="status.loading_link">
          <div class="status-text">Obteniendo vista previa...</div>
        </div>

        <div class="tool" v-if="has_errors">
          <div class="status-text error">
            <p>Hubo un error al publicar el post:</p>
            <p v-for="error in status.errors" :key="error" v-text="translate_error(error[0])"/>
          </div>
        </div>

        <div
          class="link-preview tool"
          v-if="post.links.length > 0 && !post.medias.length && !status.uploading_media"
        >
          <span class="remove-link" @click="remove_link">
            <i class="fa fa-times"></i>
          </span>
          <link-item :link="post.links[0]" @clicked="media_clicked" />
        </div>

        <attachments-zone
          :attachments="post.medias"
          @attachment-removed="remove_media"
          @clicked="media_clicked"
          v-show="canShowEditor"
          :uploading="status.uploading_media"
        ></attachments-zone>

        <div class="controls tool" v-if="canShowEditor">
          <div class="m_block">
            <input-switch class="_line" value="text" v-model="post.nsfw" :checked="post.nsfw">NSFW</input-switch>
            <button
              @click.prevent="triggerUpload"
              class="button"
              data-button-size="medium"
              data-button-font="medium"
              data-tip="Subir fotos o videos"
              data-tip-position="top"
              data-tip-text
              v-if="canAddMedias"
            >
              <i class="far fa-image"></i>
            </button>
            <form ref="imageUploadForm" method="post" enctype="multipart/form-data" class="hidden">
              <input
                type="file"
                name="file"
                accept="image/*, video/*"
                multiple
                ref="imageUploadInput"
                @change="uploadFiles"
              />
            </form>
          </div>
          <div class="m_block">
            <button
              @click.prevent="close"
              class="button"
              data-button-size="medium"
              data-button-font="medium"
              v-if="!always_open"
            >cancelar</button>
            <button
              :disabled="!canPublish"
              @click.prevent="addPost"
              class="button"
              data-button-size="medium"
              data-button-font="medium"
              data-button-important
            >publicar</button>
          </div>
        </div>
      </template>
    </div>
  </div>
</template>

<script>
import axios from "axios";
/**
 * Import utilities
 */
import moment from "moment";

/**
 * Import API interfaces
 */
import post from "../../api/post";

/**
 * Import PostCreator child components
 */
import Editor from "../Editor";
import AttachmentsZone from "./AttachmentsZone";

import LinkItem from "@/components/Link/Link";

/**
 * Import additional components
 */
import Switch from "../inputSwitch";

import VideoEmbed from "../Card/VideoEmbed";
import LinkEmbed from "../Card/LinkEmbed";

/**
 * Import helpers
 */
import { text_has_link, process_link } from "@/lib/links";

const initialData = function() {
  return {
    post: {
      body: "",
      nsfw: false,
      medias: [],
      links: [],
      tags: "",
      related_to_id: null,
      parent_id: null
    },
    status: {
      open: false,
      loading: false,
      errors: null,
      loading_link: false,
      uploading_media: false
    },
    show_overlay: false,
    request_data: null
  };
};

export default {
  name: "PostCreator",
  components: {
    Editor,
    VideoEmbed,
    LinkEmbed,
    AttachmentsZone,
    "input-switch": Switch,
    LinkItem
  },
  props: {
    related_to: {
      type: String,
      default: null
    },
    parent_id: {
      type: String,
      default: null
    },
    has_overlay: {
      type: Boolean,
      default: true
    },
    with_tags: {
      type: Boolean,
      default: true
    },
    initial_tags: {
      type: Array,
      default: () => []
    },
    flat: {
      type: Boolean,
      default: false
    },
    type: {
      type: String,
      default: "toolbox"
    },
    always_open: { type: Boolean, default: false },
    with_toolbar: {
      type: Boolean,
      default: true
    },
    autofocus: {
      type: Boolean,
      default: false
    }
  },
  data: initialData,
  computed: {
    has_errors() {
      return this.status.errors !== null;
    },
    canShowEditor() {
      if (this.always_open) return true;
      return this.status.open;
    },
    canPublish() {
      if (
        (!this.post.body &&
          !this.post.medias.length &&
          !this.post.links.length) ||
        this.status.loading
      ) {
        return false;
      }
      return true;
    },
    hasMedias() {
      return this.post.medias.length > 0;
    },
    canAddMedias() {
      return !this.related_to && this.post.medias.length < 4;
    },
    bigTextBody() {
      return (
        this.post.body &&
        this.post.body.length <= 85 &&
        !/\r|\n/.exec(this.post.body) &&
        !this.post.medias.length > 0
      );
    }
  },
  methods: {
    reply_to(username) {
      console.log(username);
      let new_body = `@${username} ${this.post.body}`;
      this.$refs.editor.update_body(new_body);
    },
    openEditor() {
      if (this.status.open) return;
      this.status.open = true;
      this.show_overlay = true;
      //this.$root.$emit("blurToolBox", true);
    },
    close() {
      this.status.open = false;
      this.show_overlay = false;
      this.$emit("closed");
      //this.$root.$emit("blurToolBox", false);
    },
    reset() {
      Object.assign(this.$data, initialData());
      this.post.tags = this.initial_tags.join(" ");
      this.$emit("reset");
    },
    updateBody(body) {
      this.post.body = body;
    },
    addPost() {
      this.prepare_request_data();

      const tags = this.request_data.tags;
      const invalid_tags = tags
        .filter(x => {
          return !/^[\w+]{2,100}$/m.test(x);
        })
        .filter(x => x != "");
      if (invalid_tags.length > 0) {
        this.warn_invalid_tags(invalid_tags);
        return;
      }

      this.attemp_post_upload();
    },
    async handlePaste(e) {
      let files = e.clipboardData.files;
      if (files.length) {
        Array.from(files).forEach(await this.uploadFile);
      }

      const text = e.clipboardData.getData("text");
      if (text_has_link(text)) {
        this.status.loading_link = true;
        const link = await process_link(text);
        this.post.links = [link];
        this.status.loading_link = false;
      }
    },
    uploadFiles(_event) {
      let files = this.$refs.imageUploadInput.files;
      Array.from(files).forEach(this.uploadFile);
      this.$refs.imageUploadInput.value = "";
    },
    async uploadFile(file) {
      this.status.uploading_media = true;
      try {
        this.validate_uploaded_file(file);
        if (this.post.medias.length == 4)
          throw "Debes eliminar una foto antes de añadir otra.";

        let formData = new FormData();
        formData.append("file", file);
        let media = (await axios.post("/api/v1/media", formData)).data;
        if (this.post.medias.length == 4)
          throw "Debes eliminar una foto antes de añadir otra.";
        this.post.medias.push(media);
      } catch (error) {
        switch (error.response.status) {
          case 413:
            this.status.errors = {media: ["el archivo que intentas subir supera los 5Mb."]};
            break;
          default:
            this.status.errors =
              {media: ["hubo un problema al subir el archivo, por favor intenta en otro momento."]};
        }
      }
      this.status.uploading_media = false;
    },
    triggerUpload() {
      this.$refs.imageUploadInput.click();
    },
    remove_media(id) {
      this.post.medias = this.post.medias.filter(o => o.id != id);
    },
    remove_link() {
      this.post.links = [];
    },
    validate_uploaded_file(file) {
      const valid_types = ["image", "video"];
      const valid_formats = ["jpg", "jpeg", "png", "gif", "mp4", "webm"];
      const [type, format] = file.type.split("/");

      if (!valid_types.includes(type) || !valid_formats.includes(format))
        throw "El formato del archivo no esta permitido. Puedes subir archivos de tipo jpg, png, gif, mp4 o webm";

      return true;
    },
    media_clicked(id) {
      let medias = this.post.medias;
      let index = this.post.medias.findIndex(m => m.id == id);
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
    prepare_request_data() {
      let requestData = {
        body: this.post.body,
        tags: this.post.tags.split(" ")
      };
      if (this.post.nsfw) {
        if (this.post.tags.length) {
          requestData.tags.push("nsfw");
        } else {
          requestData.tags = ["nsfw"];
        }
      }

      if (this.parent_id) {
        requestData.parent_id = this.parent_id;
      }

      if (this.post.medias !== null) {
        requestData.medias = this.post.medias;
      }
      if (this.post.links !== null) {
        requestData.links = this.post.links;
      }

      this.request_data = requestData;
    },
    attemp_post_upload() {
      this.status.loading = true;
      post
        .create(this.request_data)
        .then(res => {
          this.$emit("created", res);
          if (!this.parent_id) this.$store.dispatch("addFeedPost", res);

          if (
            res.nsfw &&
            this.$store.getters.settings.content_nsfw === "hide"
          ) {
            this.$notify({
              group: "top",
              text:
                "Tu post ha sido publicado, pero tus opciones de contenido no te permiten verlo. Haz click aquí para cambiarlas.",
              type: "warning",
              data: {
                close: () => {
                  this.$router.push("/settings/content");
                }
              }
            });
          }
          this.reset();
          this.close();
        })
        .catch(error => {
          switch (error.status) {
            case 422:
              this.status.errors = error.res.errors;
              break;
            case 429:
              this.status.errors = {server: ["has estado publicando demasiado, espera un momento y vuelve a intentar"]}
              break;
            case 500:
              this.status.errors =
                {server: ["hay un error en el servidor, por favor intenta en unos minutos o contacta con un administrador."]};
            default:
              throw error;
          }
        })
        .finally(() => {
          this.status.loading = false;
        });
    },
    warn_invalid_tags(invalid_tags) {
      const tags = invalid_tags.join(", ");
      this.$modal.show("dialog", {
        title:
          "El post contiene tags invalidos. ¿Deseas publicarlo de todas formas? Los tags inválidos serán omitidos.",
        text: `Los tags deben estar formados por letras(sin tilde), números, guión bajo(_) y tener entre 2 y 100 caracteres.
          Los siguientes tags son inválidos: ${tags}`,
        buttons: [
          {
            title: "Corregir",
            class: "button"
          },
          {
            title: "Publicar",
            default: true,
            class: "button danger",
            handler: () => {
              this.attemp_post_upload();
              this.$modal.hide("dialog");
            }
          }
        ],
        adaptive: true
      });
    },
    translate_error(error) {
      switch(error) {
        case "parent post does not exist": {
          return "El post al que intentas responder no existe"
        }
        case "too similar to previous posts": {
          return "Ya publicaste algo muy similar hace un momento, intenta más tarde"
        }
        case "can't comment to this user posts": {
          return "El dueño de este post ha habilitado los comentarios solo a sus seguidores"
        }
        case "parent post owner has blocked the post creator": {
          return this.parent_id
            ? "El dueño de este comentario te ha bloqueado"
            : "El dueño de este post te ha bloqueado"
        }
        default:
          return error;
      }
    }
  },
  created() {
    if (this.related_to) this.post.related_to_id = this.related_to;
    this.post.tags = this.initial_tags.join(" ");
  },
  beforeDestroy() {
    this.$root.$emit("blurToolBox", false);
  }
};
</script>

<style lang="scss">
@import "~@/../sass/base/_variables.scss";

.toolbox:not(.tool-box-open) {
  overflow: hidden;
}

.tool {
  .status-text {
    text-align: center;
    color: #ffffff77;

    &.error {
      text-align: left;
      color: $t-error;
      font-weight: bold;
    }
  }
}

.attachment {
  display: inline-block;
  margin: 2px;
  position: relative;
}

.attachment img {
  width: 64px;
  border-radius: 2px;
}

.attachment:hover {
  opacity: 1;
}

.link-preview {
  position: relative;
}

.remove-link {
  opacity: 0.7;
  cursor: pointer;
  position: absolute;
  top: 2px;
  right: 10px;
  color: white;
  font-size: 1rem;
  background: $narrojo;
  padding: 1px;
  width: 1.2em;
  height: 1.2em;
  box-sizing: border-box;
  display: block;
  text-align: center;
  border-radius: 2px;
  z-index: 20;

  &:hover {
    opacity: 1;
  }
  @media #{$query-mobile} {
    width: 2em !important;
    height: 2em !important;
    font-size: 1.2em !important;
    border-radius: 50% !important;
    line-height: 1.8em !important;
    border: 2px solid #ffffffcc;
    box-sizing: border-box;
    right: 5px !important;
    top: 5px !important;
  }
}
</style>
