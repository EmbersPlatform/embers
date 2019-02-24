<template>
  <div
    class="toolbox"
    :class="{'tool-box-open': canShowEditor, 'renderbox': status.loading}"
    data-renderbox-message="Publicando..."
  >
    <div class="toolbox__overlay" v-if="has_overlay && show_overlay" @click="close"></div>
    <div class="toolbox__container">
      <template v-if="!status.loading">
        <Editor
          type="toolbox"
          @update="updateBody"
          @paste="handlePaste"
          @focus="openEditor"
          :class="{'compressed': !canShowEditor, 'big-text': bigTextBody}"
          data-editor-style="toolbox"
          rel="editor"
        ></Editor>
        <div class="tags-wrapper tool" :class="{'compact':!canPublish || !canShowEditor}">
          <input type="text" placeholder="Tags separados por espacios" v-model="post.tags">
        </div>

        <attachments-zone
          :attachments="post.medias"
          @attachment-removed="remove_media"
          @clicked="media_clicked"
          v-show="canShowEditor"
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
              >
            </form>
          </div>
          <div class="m_block">
            <button
              @click.prevent="close"
              class="button"
              data-button-size="medium"
              data-button-font="medium"
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
      <media-slides
        v-if="show_media_slides"
        :medias="post.medias"
        :index="clicked_media_index"
        @closed="show_media_slides = false"
      ></media-slides>
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
import AudioRecorder from "./AudioRecorder";
import AttachmentsZone from "./AttachmentsZone";

import MediaSlides from "@/components/Media/MediaSlides";

/**
 * Import additional components
 */
import Switch from "../inputSwitch";

import VideoEmbed from "../Card/VideoEmbed";
import LinkEmbed from "../Card/LinkEmbed";
import AudioPlayer from "../Card/AudioPlayer";

const initialData = function() {
  return {
    post: {
      body: null,
      nsfw: false,
      medias: [],
      tags: "",
      related_to_id: null
    },
    status: {
      open: false,
      loading: false,
      errors: null,
      recordingAudio: false
    },
    show_overlay: false,
    show_media_slides: false,
    clicked_media_index: 0
  };
};

export default {
  name: "PostCreator",
  components: {
    Editor,
    AudioRecorder,
    VideoEmbed,
    LinkEmbed,
    AudioPlayer,
    AttachmentsZone,
    MediaSlides,
    "input-switch": Switch
  },
  props: {
    related_to: {
      type: String,
      default: null
    },
    has_overlay: {
      type: Boolean,
      default: true
    }
  },
  data: initialData,
  computed: {
    canShowEditor() {
      return this.status.open;
    },
    canShowAudioRecorder() {
      return this.canShowEditor && this.status.recordingAudio;
    },
    canPublish() {
      if (!this.post.body && !this.post.medias.length) {
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
    openEditor() {
      if (this.status.open) return;
      this.status.open = true;
      this.show_overlay = true;
      //this.$root.$emit("blurToolBox", true);
    },
    close() {
      this.status.open = false;
      this.show_overlay = false;
      //this.$root.$emit("blurToolBox", false);
    },
    reset() {
      Object.assign(this.$data, initialData());
      this.$emit("reset");
    },
    updateBody(body) {
      this.post.body = body;
    },
    addPost() {
      this.status.loading = true;

      let requestData = {
        body: this.post.body,
        nsfw: this.post.nsfw,
        tags: this.post.tags.split(" ")
      };

      if (this.post.medias !== null) {
        requestData.medias = this.post.medias;
      }
      post
        .create(requestData)
        .then(res => {
          this.$store.dispatch("addFeedPost", res);
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
        })
        .finally(() => {
          this.reset();
          this.close();
        });
    },
    handlePaste(e) {
      let files = e.clipboardData.files;
      Array.from(files).forEach(this.uploadFile);

      let text = e.clipboardData.getData("text");
      let urlRegex = /(?:(?:https?|ftp):\/\/)(?:\S+(?::\S*)?@)?(?:(?!10(?:\.\d{1,3}){3})(?!127(?:\.​\d{1,3}){3})(?!169\.254(?:\.\d{1,3}){2})(?!192\.168(?:\.\d{1,3}){2})(?!172\.(?:1[​6-9]|2\d|3[0-1])(?:\.\d{1,3}){2})(?:[1-9]\d?|1\d\d|2[01]\d|22[0-3])(?:\.(?:1?\d{1​,2}|2[0-4]\d|25[0-5])){2}(?:\.(?:[1-9]\d?|1\d\d|2[0-4]\d|25[0-4]))|(?:(?:[a-z\u00​a1-\uffff0-9]+-?)*[a-z\u00a1-\uffff0-9]+)(?:\.(?:[a-z\u00a1-\uffff0-9]+-?)*[a-z\u​00a1-\uffff0-9]+)*(?:\.(?:[a-z\u00a1-\uffff]{2,})))(?::\d{2,5})?(?:\/[^\s]*)?/g;
      if (urlRegex.test(text)) {
        // An url was pasted, parse it
        console.log("Handle pasted link");
      }
    },
    uploadFiles(_event) {
      let files = this.$refs.imageUploadInput.files;
      Array.from(files).forEach(this.uploadFile);
      this.$refs.imageUploadInput.value = "";
    },
    async uploadFile(file) {
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
        this.$notify({
          group: "top",
          text: error,
          type: "error"
        });
      }
    },
    triggerUpload() {
      this.$refs.imageUploadInput.click();
    },
    remove_media(id) {
      this.post.medias = this.post.medias.filter(o => o.id != id);
    },
    validate_uploaded_file(file) {
      const valid_types = ["image", "video"];
      const valid_formats = ["jpg", "jpeg", "png", "gif", "mp4", "webm"];
      const [type, format] = file.type.split("/");

      if (!valid_types.includes(type) || !valid_formats.includes(format))
        throw "El formato del archivo no esta permitido. Puedes subir archivos de tipo jpg, png, gif, mp4 o webm";

      return true;
    },
    media_clicked(index) {
      this.clicked_media_index = index;
      this.show_media_slides = true;
    }
  },
  created() {
    if (this.related_to) this.post.related_to_id = this.related_to;
    window.addEventListener("beforeunload", e => {
      if (this.post.body !== null || this.hasMedias) {
        var confirmationMessage =
          "El post que estabas editando se perderá para siempre. ¡Eso es mucho tiempo!";
        e.returnValue = confirmationMessage;
        return confirmationMessage;
      }
    });
  },
  beforeDestroy() {
    this.$root.$emit("blurToolBox", false);
  }
};
</script>

<style>
.attachment {
  display: inline-block;
  margin: 2px;
  opacity: 0.75;
  position: relative;
}

.attachment img {
  width: 64px;
  border-radius: 2px;
}

.attachment:hover {
  opacity: 1;
}
</style>
