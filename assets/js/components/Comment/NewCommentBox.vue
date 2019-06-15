<template>
  <div class="new-comment">
    <div class="comment">
      <header class="header">
        <avatar v-if="$mq != 'sm'" :avatar="$store.getters.user.avatar.small"></avatar>
        <Editor
          :show="canShowEditor"
          type="comment"
          @update="updateBody"
          data-editor-style="normal"
        ></Editor>
      </header>
      <div class="controls">
        <button
          :disabled="!canPublish"
          @click.prevent="postComment"
          class="button"
          data-button-size="medium"
          data-button-font="medium"
          data-button-important
        >comentar</button>
      </div>
    </div>
  </div>
</template>

<script>
import post from "../../api/post";
import comment from "../../api/comment";
import formatter from "@/lib/formatter";
import textSelectionEdit from "@/lib/textSelectionEdit";
import EmojiPicker from "./../EmojiPicker";
import avatar from "@/components/Avatar";
import Editor from "../Editor";

export default {
  props: ["postId"],
  components: { "emoji-picker": EmojiPicker, avatar, Editor },
  data() {
    return {
      loading: false,
      body: "",
      show_characters_counter: false,
      characters_limit: 255,
      characters_left: 255,
      preview: false
    };
  },

  computed: {
    formattedBody() {
      return formatter.format(this.body, true);
    },
    canPublish() {
      if (this.body && !this.loading) {
        return true;
      }
      return false;
    },
    canShowEditor() {
      return !this.loading && this.body === null;
    }
  },
  methods: {
    updateBody(body) {
      this.body = body;
    },
    updateCharactersLeft() {
      let bodyLength = this.body && this.body.length ? this.body.length : 0;
      let charLeft = this.characters_limit - bodyLength;

      this.show_characters_counter = charLeft < 50;
      this.characters_left = charLeft;
    },
    /**
     * Posts a comment
     */
    postComment() {
      if (!this.body) return;

      this.loading = true;
      post
        .create({
          parent_id: this.postId,
          body: this.body
        })
        .then(res => {
          this.$emit("created", res);
          this.reset();
        })
        .finally(() => (this.loading = false)); // re-enable button
    },

    /**
     * Resets the comment box state
     */
    reset() {
      this.body = null;
      this.updateCharactersLeft();
    }
  }
};
</script>
