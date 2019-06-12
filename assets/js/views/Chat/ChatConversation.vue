<template>
  <div id="content" class="chat-conversation" data-layout-type="chat">
    <template v-if="!loading_party">
      <div class="chat-header">
        <avatar :avatar="party.avatar.small" :status="party.status == 'online'"/>
        <div class="chat-header__content">
          <p>
            <strong>{{party.username}}</strong>
          </p>
          <p class="chat-header__status" v-text="status_text"></p>
        </div>
      </div>
      <div class="chat-content" ref="content">
        <template v-if="!loading_messages">
          <div class="message-block" v-for="(block, index) in reduced_messages" :key="index">
            <avatar
              v-if="block.messages[0].sender_id != user.id || $mq != 'sm'"
              :avatar="block.messages[0].sender.avatar.small"
            />
            <div class="message-block__messages">
              <div
                class="message-block__header"
                :class="{mine: block.messages[0].sender.id == user.id}"
              >
                <strong>{{ block.messages[0].sender.username }}</strong>
                <span>-</span>
                <span>{{ $moment.utc(block.timestamp).local().from() }}</span>
              </div>
              <chat-message
                v-for="(message, index) in block.messages"
                :key="index"
                :message="message"
              ></chat-message>
            </div>
          </div>
          <div class="message-block" v-if="is_typing">
            <avatar :avatar="party.avatar.small"/>
            <div class="message-block__messages">
              <chat-message typing :user="this.party"></chat-message>
            </div>
          </div>
        </template>
        <h3 v-else class="loading-title">Cargando mensajes...</h3>
        <intersector @intersect="read_conversation" style="height: 1px;"/>
      </div>
      <div class="chat-editor">
        <textarea
          data-autoresize
          v-model="text"
          @keydown.enter.exact.prevent
          @keyup.enter.exact="send_message"
          @keydown.exact="send_typing"
          @keydown.enter.shift.exact="newline"
          placeholder="Escribe un mensaje..."
          @focus="input_focus"
          @blur="toggle_navigation(true)"
        ></textarea>
      </div>
    </template>
    <h3 v-else class="loading-title">Cargando conversacion...</h3>
  </div>
</template>
<script>
import axios from "axios";
import avatar from "@/components/Avatar";

import formatter from "@/lib/formatter";

import EventBus from "@/lib/event_bus";

import ChatMessage from "@/components/Chat/ChatMessage";
import Intersector from "@/components/Intersector";

import { mapGetters, mapState } from "vuex";
import _ from "lodash";

import sockets from "@/lib/socket";

export default {
  name: "ChatConversation",
  components: { avatar, ChatMessage, Intersector },
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
    party_user: null,
    messages: [],
    new_messages_buffer: [],
    text: "",
    is_typing: false,
    is_typing_timeout: null
  }),
  computed: {
    ...mapGetters(["user"]),
    ...mapState("chat", ["online_friends"]),
    party() {
      let party = this.party_user;
      party.status =
        _.find(this.online_friends, friend => friend.id == party.id) !=
          undefined || party.id == this.user.id
          ? "online"
          : "";
      return party;
    },
    status_text() {
      if (this.is_typing) return "Escribiendo...";
      if (this.party.status == "online") return "Conectado";
      return "Desconectado";
    },
    reduced_messages() {
      const acc = this.messages.reduce(
        (acc, m, i, arr) => {
          if (i == 0) {
            acc.blocks[acc.index] = { timestamp: m.inserted_at, messages: [m] };
            return acc;
          } else {
            const curren_timestamp = this.$moment(arr[i].inserted_at).format(
              "X"
            );
            const previous_timestamp = this.$moment(
              arr[i - 1].inserted_at
            ).format("X");
            // If 5 minutes elapsed from last message, message is new enough to be put in a separate block
            const too_new = curren_timestamp - 600 >= previous_timestamp;
            if (too_new || arr[i - 1].sender.id != m.sender.id) {
              acc.index++;
              acc.blocks[acc.index] = {
                timestamp: m.inserted_at,
                messages: [m]
              };
              return acc;
            } else {
              acc.blocks[acc.index].messages.push(m);
              return acc;
            }
          }
        },
        { index: 0, blocks: [] }
      );
      return acc.blocks;
    }
  },
  methods: {
    async init() {
      this.messages = [];
      this.party_user = null;
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
          this.party_user = party.data;
        } catch (e) {
          this.$router.replace("/chat");
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
    send_typing({ key }) {
      if (key == "Enter") return;
      setTimeout(() =>
        sockets.channels.user.push("chat_typing", { party: this.party.id }, 300)
      );
    },
    track_typing(payload) {
      if (payload.party != this.party.id) return;
      this.is_typing = true;
      clearTimeout(this.is_typing_timeout);

      this.is_typing_timeout = setTimeout(() => (this.is_typing = false), 900);
    },
    empty_buffer() {
      this.new_messages_buffer = [];
    },
    new_message_callback({ message, temp_id }) {
      if (
        (message.receiver_id == this.party.id &&
          message.sender_id == this.user.id) ||
        (message.sender_id == this.party.id &&
          message.receiver_id == this.user.id) ||
        (message.sender_id == this.user.id &&
          message.receiver_id == this.user.id)
      ) {
        if (this.loading_messages) {
          this.new_messages_buffer.push(message);
        }
        const index = this.messages.findIndex(x => {
          return x.optimistic && x.temp_id == temp_id;
        });
        if (index > -1) {
          this.messages[index] = message;
        } else {
          this.messages.push(message);
        }
        if (
          this.$refs.content.scrollTop >=
          this.$refs.content.scrollHeight - this.$refs.content.offsetHeight
        ) {
          this.scroll_to_bottom();
          this.read_conversation();
        }
      }
    },
    async read_conversation() {
      this.$store.dispatch("chat/read_conversation_with", this.party.id);
      await axios.put(`/api/v1/chat/conversations/${this.party.id}`);
    },
    scroll_to_bottom() {
      this.$nextTick(() => {
        this.$refs.content.scrollTop = this.$refs.content.scrollHeight;
      });
    },
    send_message() {
      const text = this.text.trim();
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
    newline() {
      this.text = `${this.text}\n`;
    },
    input_focus() {
      this.toggle_navigation(false);
      this.read_conversation();
    },
    toggle_navigation(value) {
      if (this.$mq != "sm") return;
      EventBus.$emit("toggle_navigation", value);
    }
  },
  async created() {
    EventBus.$on("new_chat_message", this.new_message_callback);
    EventBus.$on("chat_typing", this.track_typing);
    this.init();
  },
  beforeDestroy() {
    EventBus.$off("new_chat_message", this.new_message_callback);
    EventBus.$off("chat_typing", this.track_typing);
    clearTimeout(this.is_typing_timeout);
  },
  watch: {
    party_id(val) {
      this.init(val);
    }
  }
};
</script>

<style lang="scss">
@import "~@/../sass/base/_variables.scss";

.chat-conversation {
  display: flex;
  flex-direction: column;
  height: 100%;
  overflow: hidden;
}

.chat-header {
  color: #ffffffcc;
  flex-shrink: 0;
  padding: 10px 0 5px 0;
  display: flex;
  flex-direction: row;
  border-bottom: 1px solid #00000020;

  .avatar {
    width: 40px;
    height: 40px;
  }
}

.chat-header__content {
  padding: 0 10px;
}

.chat-header__status {
  font-size: 0.9em;
  margin-top: 5px;
  opacity: 0.7;
}

.chat-content {
  padding-top: 10px;
  flex: 1;
  max-height: 100%;
  overflow-y: auto;
  box-sizing: border-box;
}

.chat-editor {
  flex-shrink: 0;
  padding: 5px 0;

  textarea {
    box-sizing: border-box;
    width: 100%;
    color: #ffffffcc;
    background: transparent;
    border: 1px solid #00000050;
    border-radius: 2px;
    padding: 5px 10px;
  }
}

.message-block {
  display: flex;
  align-items: flex-start;
  flex-grow: 1;
  margin-bottom: 5px;

  .avatar {
    width: 40px;
    height: 40px;
    margin-right: 10px;
    position: sticky;
    margin-top: 5px;
    top: 0;
  }
}

.message-block__header {
  padding: 5px 0;
  color: #ffffffcc;
  display: flex;
  align-items: center;

  &.mine {
    @media #{$query-mobile} {
      text-align: right;

      flex-direction: row-reverse;

      *:not(:last-child) {
        margin-right: 0;
        margin-left: 5px;
      }
    }
  }

  span {
    color: #ffffff70;
    font-size: 0.8em;
  }

  *:not(:last-child) {
    margin-right: 5px;
  }
}

.message-block__messages {
  padding-top: 5px;
  flex-grow: 1;
}

.loading-title {
  color: #ffffff99;
}
</style>
