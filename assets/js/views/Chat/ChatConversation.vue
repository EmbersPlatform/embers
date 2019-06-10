<template>
  <div id="content" class="chat-conversation" data-layout-type="chat">
    <template v-if="!loading_party">
      <div class="chat-header">
        <h3>Conversacion con @{{party.username}}</h3>
      </div>
      <div class="chat-content" ref="content">
        <template v-if="!loading_messages">
          <chat-message
            v-for="(message, index) in messages"
            :key="index"
            :message="message"
            @sent="message_sent(index)"
          ></chat-message>
        </template>
        <h3 v-else>Cargando mensajes...</h3>
      </div>
      <div class="chat-editor">
        <input
          type="text"
          v-model="text"
          @keyup.enter="send_message"
          placeholder="Escribe un mensaje..."
          @focus="toggle_navigation(false)"
          @blur="toggle_navigation(true)"
        >
      </div>
    </template>
    <h3 v-else>Cargando conversacion...</h3>
  </div>
</template>
<script>
import axios from "axios";
import avatar from "@/components/Avatar";

import formatter from "@/lib/formatter";

import EventBus from "@/lib/event_bus";

import ChatMessage from "@/components/Chat/ChatMessage";

import { mapGetters } from "vuex";

export default {
  name: "ChatConversation",
  components: { avatar, ChatMessage },
  props: {
    party_id: {
      type: String,
      required: true
    }
  },
  data: () => ({
    loading_party: false,
    loading_messages: false,
    loading_older_messages: false,
    party: null,
    messages: [],
    new_messages_buffer: [],
    text: ""
  }),
  computed: {
    ...mapGetters(["user"])
  },
  methods: {
    async init() {
      this.messages = [];
      this.party = null;
      await this.get_party();
      await this.load_messages();
    },
    async get_party() {
      if (this.party_id) {
        this.loading_party = true;
        try {
          const { data: party } = await axios.get(
            `/api/v1/users/${this.party_id}`
          );
          this.party = party.data;
        } catch (e) {
          console.error(e);
        }
        this.loading_party = false;
      }
    },
    async load_messages() {
      this.loading_messages = true;
      const party_id = this.party.id;
      let { data: results } = await axios.get(
        `/api/v1/chat/conversations/${party_id}`
      );
      let messages = results.items.reverse();

      messages.push(...this.new_messages_buffer);
      this.empty_buffer();

      this.messages = messages;
      this.read_conversation();
      this.scroll_to_bottom();
      this.loading_messages = false;
    },
    empty_buffer() {
      this.new_messages_buffer = [];
    },
    new_message_callback(message) {
      if (
        message.receiver_id == this.party.id ||
        message.sender_id == this.party.id
      ) {
        if (this.loading_messages) {
          this.new_messages_buffer.push(message);
        } else {
          this.messages.push(message);
        }
        if (
          this.$refs.content.scrollTop >=
          this.$refs.content.scrollHeight - this.$refs.content.offsetHeight
        )
          this.scroll_to_bottom();
        this.read_conversation();
      }
    },
    async read_conversation() {
      await axios.put(`/api/v1/chat/conversations/${this.party.id}`);
    },
    scroll_to_bottom() {
      this.$nextTick(() => {
        this.$refs.content.scrollTop = this.$refs.content.scrollHeight;
      });
    },
    send_message() {
      const text = this.text;
      if (!text.length) return;
      this.messages.push({
        sender_id: this.user.id,
        sender: this.user,
        receiver_id: this.party.id,
        text: text,
        optimistic: true,
        temp_id: +new Date()
      });
      this.text = "";
      this.scroll_to_bottom();
    },
    message_sent(index) {
      this.messages.splice(index, 1);
    },
    toggle_navigation(value) {
      if (this.$mq != "sm") return;
      EventBus.$emit("toggle_navigation", value);
    }
  },
  async created() {
    EventBus.$on("new_chat_message", this.new_message_callback);
    this.init();
  },
  beforeDestroy() {
    EventBus.$off("new_chat_message", this.new_message_callback);
  },
  watch: {
    party_id(val) {
      this.init(val);
    }
  }
};
</script>

<style lang="scss">
.chat-conversation {
  display: flex;
  flex-direction: column;
  height: 100%;
  overflow: hidden;
}

.chat-header {
  flex-shrink: 0;
  padding: 5px 10px;
}

.chat-content {
  flex-grow: 1;
  max-height: 100%;
  overflow-y: auto;
  box-sizing: border-box;
}

.chat-editor {
  flex-shrink: 0;
  padding: 5px 0;

  input {
    box-sizing: border-box;
    width: 100%;
    color: #ffffffcc;
    background: transparent;
    border: 1px solid #00000050;
    border-radius: 2px;
    padding: 5px 10px;
  }
}
</style>
