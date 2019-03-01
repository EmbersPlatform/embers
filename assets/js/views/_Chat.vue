<template>
  <div id="board">
    <div id="heading">
      <Top></Top>
    </div>
    <div id="wrapper" @click.prevent="markAsRead">
      <template v-if="showConversation">
        <ChatConversation></ChatConversation>
        <Editor :show="canSendMessage" type="chat" @send="submitMessage" data-editor-style="chat"></Editor>
      </template>
      <div v-else id="content" data-layout-type="middle">
        <div id="feed" :class="{renderbox : loading}">
          <h3>
            <p>Hmm. Esto está muy vacío</p>
          </h3>
          <!-- <button class="button" data-button-size="big" data-button-font="medium" data-button-uppercase data-button-important>
						Iniciar una nueva conversacion
          </button>-->
        </div>
      </div>
      <NewChatModal v-if="show_new_chat_modal"></NewChatModal>
    </div>
  </div>
</template>
<script>
import Top from "../components/Top";
import ChatConversation from "./Chat/ChatConversation";
const NewChatModal = () => import("./Chat/NewChatModal");
import Editor from "../components/Editor";

import chatAPI from "../api/conversation";
import userAPI from "../api/user";

import { mapGetters } from "vuex";

export default {
  name: "Chat",
  components: {
    Top,
    ChatConversation,
    NewChatModal,
    Editor
  },
  data() {
    return {
      sendingMessage: false,
      loading: false
    };
  },
  computed: {
    ...mapGetters("chat", ["conversation", "show_new_chat_modal"]),
    showConversation() {
      return this.conversation !== null;
    },
    canSendMessage() {
      return this.sendingMessage;
    }
  },
  methods: {
    loadConversations() {
      return new Promise((resolve, reject) => {
        chatAPI
          .get()
          .then(conversations => {
            this.$store.dispatch("chat/updateConversations", conversations);
            resolve(conversations);
          })
          .catch(err => {
            reject(err);
          });
      });
    },
    submitMessage(data) {
      let content = data;
      if (content.trim().length <= 0) {
        return;
      }
      this.sendingMessage = true;
      chatAPI
        .sendMessage(this.conversation.user.id, { content: content })
        .then(message => {
          if (this.conversation.draft) {
            let conversation = this.conversation;
            conversation.draft = false;
            conversation.unread = 0;
            conversation.id = message.chat_conversation_id;
            this.$store.dispatch("chat/updateConversation", conversation);
            this.$store.dispatch("chat/addConversation", conversation);
          }
          this.$store.dispatch("chat/addMessage", message);
          // this.$refs.chatEditorTextarea.value = '';
          this.$root.$emit("chat/scrollToBottom");
        })
        .finally(() => {
          this.sendingMessage = false;
        });
    },
    markAsRead() {
      this.$store.dispatch("chat/newMessage", false);
      this.$store.dispatch("chat/markConversationAsRead", this.conversation.id);
      chatAPI.markAsRead(this.conversation.user.id);
    }
  },
  created() {
    this.loadConversations().then(conversations => {
      if (this.$route.params.id) {
        let conversation = _.find(conversations, o => {
          return o.user.id == this.$route.params.id;
        });
        if (conversation) {
          this.$store.dispatch("chat/updateConversation", conversation);
        }
      }
    });
  },
  watch: {
    conversation(conversation) {
      if (!conversation) return;
      this.$router.push(`/chat/${conversation.user.id}`);
    }
    // check route change Ej: from chat/2 to chat/ and clear window
    // '$route': ''
  }
};
</script>
