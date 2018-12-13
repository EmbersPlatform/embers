<template>
  <ul id="column">
    <li class="nav_">
      <h2>conversaciones</h2>
      <ul>
        <li class="n_item">
          <button id="new_conversation" class="n_i_wrap" @click="showNewChatModal">
            <avatar svg="s_plus"></avatar>
            <span class="n_i_w_content">nuevo mensaje</span>
          </button>
        </li>
      </ul>
    </li>
    <li class="nav_ nav-grow">
      <ul :class="{'renderbox' : loading}">
        <li v-for="conversation in conversations" class="n_item" :key="conversation.id">
          <span
            @click="conversationSelected(conversation)"
            active-class="active"
            class="n_i_wrap"
            :data-count="[conversation.unread <= 9 ? conversation.unread : '9+']"
          >
            <avatar :avatar="conversation.user.avatar.small"></avatar>
            <span
              class="n_i_w_content u_name"
              :data-badge="`${conversation.user.badges[0]}`"
            >{{conversation.user.name}}</span>
          </span>
        </li>
      </ul>
    </li>
  </ul>
</template>
<script>
import chatAPI from "@/api/conversation";
import avatar from "@/components/Avatar";

import { mapGetters } from "vuex";

import _ from "lodash";

export default {
  name: "SB_Chat",
  components: { avatar },
  data() {
    return {
      loading: false
    };
  },
  computed: {
    ...mapGetters("chat", ["conversations"]),
    hasConversations() {
      return this.conversations && this.conversations.length > 0;
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
    conversationSelected(conversation) {
      this.$store.dispatch("chat/updateConversation", conversation);
    },
    showNewChatModal() {
      this.$store.dispatch("chat/toggleNewChatModal", true);
      this.$root.$emit("blurSidebar", true);
    },
    markAsRead() {
      this.$store.dispatch("chat/newMessage", false);
      this.$store.dispatch("chat/markConversationAsRead", this.conversation.id);
      chatAPI.markAsRead(this.conversation.user.id);
    }
  },
  created() {
    this.loadConversations();
  }
};
</script>
