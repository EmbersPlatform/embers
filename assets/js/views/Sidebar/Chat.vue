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
        <li v-for="conversation in mapped_conversations" :key="conversation.id" class="n_item">
          <router-link
            active-class="active"
            :to="`/chat/${conversation.canonical}`"
            class="n_i_wrap"
            :data-count="unread_conversations.includes(conversation.id) ? '•' : false"
          >
            <avatar :avatar="conversation.avatar.small" :status="conversation.status"></avatar>
            <span class="n_i_w_content u_name">{{conversation.username}}</span>
          </router-link>
        </li>
      </ul>
    </li>
  </ul>
</template>
<script>
import axios from "axios";
import avatar from "@/components/Avatar";
import EventBus from "@/lib/event_bus";

import { mapGetters, mapState } from "vuex";

import _ from "lodash";

export default {
  name: "SB_Chat",
  components: { avatar },
  data: () => ({
    loading: false,
    conversations: []
  }),
  computed: {
    ...mapState("chat", ["unread_conversations", "online_friends"]),
    ...mapGetters(["user"]),
    hasConversations() {
      return this.conversations && this.conversations.length > 0;
    },
    mapped_conversations() {
      return this.conversations.map(user => {
        user.status =
          _.find(this.online_friends, friend => friend.id == user.id) !=
          undefined
            ? "online"
            : "";
        return user;
      });
    }
  },
  methods: {
    async loadConversations() {
      const { data: conversations } = await axios.get(
        "/api/v1/chat/conversations"
      );
      this.conversations = conversations;
    },
    add_conversation(message) {
      console.log("okasd", message);
      const sender = message.sender;
      const receiver = message.receiver;
      let user = null;
      if (sender.id == this.user.id) {
        user = receiver;
      }
      if (receiver.id == this.user.id) {
        user = sender;
      }
      this.conversations = _.uniqBy([user, ...this.conversations], x => x.id);
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
    EventBus.$on("new_chat_message", this.add_conversation);
  },
  beforeDestroy() {
    EventBus.$off("new_chat_message", this.add_conversation);
  }
};
</script>
