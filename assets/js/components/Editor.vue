<template>
  <div class="editor">
    <ul class="toolbar">
      <li @click="format('bold')">
        <i class="fas fa-bold"></i>
      </li>
      <li @click="format('italic')">
        <i class="fas fa-italic"></i>
      </li>
      <li @click="format('strikethrough')">
        <i class="fas fa-strikethrough"></i>
      </li>
      <li v-if="type == 'comment'" @click="insertImage">
        <i class="fas fa-image"></i>
      </li>
      <li @click="format('code')">
        <i class="fas fa-code"></i>
      </li>
      <emoji-picker @selected="addEmoji"></emoji-picker>
      <li :class="{active: preview}" @click="previewPost">
        <i class="fas fa-eye"></i>
      </li>
      <li @click="showHelp">
        <i class="fas fa-question"></i>
      </li>
    </ul>
    <div class="canvas" :data-title="canvasTitle">
      <textarea
        class="markup"
        @input="e => body=e.target.value"
        :value="body"
        ref="textarea"
        data-autoresize
        v-show="!preview"
        :placeholder="placeholder"
        @keydown="isKey"
        @paste="onPaste"
        @focus="onFocus"
      ></textarea>
      <div class="markup preview" v-if="preview" v-html="formattedBody"></div>
    </div>
  </div>
</template>

<script>
import formatter from "@/lib/formatter";
import textSelectionEdit from "@/lib/textSelectionEdit";
import EmojiPicker from "./EmojiPicker";
import attachment from "../api/attachment";
import InsertImageModal from "./Modals/InsertImageModal";

function initialData() {
  return {
    body: "",
    preview: false
  };
}
export default {
  props: ["attachment", "show", "type"],
  components: { "emoji-picker": EmojiPicker },
  data: initialData,
  computed: {
    canvasTitle() {
      switch (this.type) {
        case "comment":
          var title = "Nuevo comentario:";
          break;
        case "toolbox":
          var title = "Nuevo post:";
          break;
        default:
          var title = "Redactor:";
          break;
      }
      return this.preview ? "Vista previa:" : title;
    },
    placeholder() {
      switch (this.type) {
        case "comment":
          var placeholder = "Escribe tu comentario";
          break;
        case "toolbox":
          var placeholder = "Comparte algo con tus seguidores";
          break;
        case "chat":
          var placeholder = "Enviar mensaje";
          break;
        default:
          var placeholder = "Escribe algo interesante";
          break;
      }
      return !this.attachment
        ? placeholder + "..."
        : "Si quieres, puedes añadir una descripción...";
    },
    formattedBody() {
      return formatter.format(this.body, true);
    }
  },
  methods: {
    resetData() {
      Object.assign(this.$data, initialData());
    },
    previewPost() {
      this.preview = !this.preview;
    },
    format(what, text = null) {
      var textarea = this.$refs.textarea;
      switch (what) {
        case "bold":
          textSelectionEdit(textarea, "**", "**");
          break;
        case "italic":
          textSelectionEdit(textarea, "*", "*");
          break;
        case "strikethrough":
          textSelectionEdit(textarea, "~~", "~~");
          break;
        case "code":
          textSelectionEdit(textarea, "`", "`");
          break;
      }
      this.body = textarea.value;
    },
    insertImage() {
      this.$modal.show(
        InsertImageModal,
        { editorId: this._uid },
        { height: "auto", adaptive: true, maxWidth: 400 }
      );
    },
    addEmoji(emoji) {
      var textarea = this.$refs.textarea;
      if (emoji.custom) {
        textSelectionEdit(textarea, emoji.colons);
      } else {
        textSelectionEdit(textarea, emoji.native);
      }
      this.body = textarea.value;
    },
    isKey(e) {
      if (this.type == "chat") {
        if (e.keyCode === 13 && !e.shiftKey) {
          // Only submit if enter key was pressed
          // The combination shift+enter will result in a newline
          e.preventDefault();
          this.$emit("send", this.body);
        }
      }
    },
    onPaste(e) {
      this.$emit("paste", e);
    },
    onFocus(e) {
      this.$emit("focus", e);
    },
    showHelp() {
      this.$modal.show(
        "dialog",
        {
          title: "Sintaxis del editor",
          text: formatter.format(
            "*cursiva*: \\*cursiva\\* o \\_cursiva\\_\r\n" +
              "**negrita**: \\*\\*negrita** o \\_\\_negrita\\_\\_\r\n" +
              "`codigo`: \\`codigo\\`\r\n" +
              "~~tachado~~: \\~\\~tachado\\~\\~\r\n" +
              "imagen: `![](url)` *sólo en comentarios*\r\n" +
              "Mencionar a un usuario: `@usuario`\r\n" +
              ">be me\n" +
              ">greentexting outside of 4chan"
          ),
          buttons: [
            {
              title: "Cerrar",
              class: "button"
            }
          ]
        },
        {
          height: "auto"
        }
      );
    }
  },

  watch: {
    body(val, oldVal) {
      if (this.type != "chat") {
        this.$emit("update", val);
      }
    },
    show() {
      this.resetData();
    }
  },
  created() {
    this.$root.$on("reply comment", user => {
      textSelectionEdit(this.$refs.textarea, "@" + user + " ");
    });

    this.$parent.$on("reset", () => {
      this.resetData();
    });

    this.$root.$on(this._uid + "-insert-image", url => {
      let textarea = this.$refs.textarea;
      if (url && url !== "") {
        this.body =
          textarea.value.substring(0, textarea.selectionStart) +
          "![](" +
          url +
          ")" +
          textarea.value.substring(
            textarea.selectionEnd,
            textarea.value.length
          );
      }
    });
  }
};
</script>
