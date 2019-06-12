<template>
  <div
    v-if="!typing"
    class="chat-message"
    :class="{mine: mine, sending: sending, failed: failed}"
    @click="retry"
  >
    <div class="chat-message__content">
      <div class="chat-message__bubble" v-html="formatted_text"></div>
      <div
        v-if="failed"
        class="chat-message__error"
      >No se pudo enviar el mensaje, haz clic para volver a intentarlo.</div>
    </div>
  </div>
  <div v-else class="chat-message">
    <div class="chat-message__content">
      <div class="chat-message__bubble typing">
        <span></span>
        <span></span>
        <span></span>
      </div>
    </div>
  </div>
</template>

<script>
import axios from "axios";
import { mapGetters } from "vuex";
import Avatar from "@/components/Avatar";
import formatter from "@/lib/formatter";

export default {
  name: "ChatMessage",
  components: { Avatar },
  props: {
    message: {
      type: Object,
      required: true
    },
    typing: {
      type: Boolean,
      default: false
    }
  },
  computed: {
    ...mapGetters(["user"]),
    mine() {
      return this.message.sender.id == this.user.id;
    },
    optimistic() {
      return this.message.optimistic;
    },
    formatted_text() {
      return formatter.format(this.message.text);
    }
  },
  data: () => ({
    sending: false,
    failed: false
  }),
  methods: {
    async send() {
      this.sending = true;
      try {
        const { data: message } = await axios.post(
          `/api/v1/chat/conversations`,
          {
            receiver_id: this.message.receiver_id,
            text: this.message.text,
            temp_id: this.message.temp_id
          }
        );
        this.sending = false;
        this.$emit("sent", this.message.temp_id);
      } catch (e) {
        console.error(e);
        this.failed = true;
      }
    },
    retry() {
      if (this.failed) {
        this.send();
      }
    }
  },
  created() {
    if (this.message.optimistic) {
      this.send();
    }
  }
};
</script>

<style lang="scss">
@import "~@/../sass/base/_variables.scss";

.chat-message {
  display: flex;
  flex-direction: row;
  margin-bottom: 5px;
  .chat-message__content {
    display: flex;
    flex-direction: column;
    box-sizing: border-box;
    flex: 1;
    .chat-message__bubble {
      background: $blue_dark;
      color: #ffffffdd;
      padding: 5px 10px;
      border-radius: 14px;
      width: fit-content;
      word-break: break-word;
      max-width: 80%;

      &.typing span {
        width: 5px;
        height: 5px;
        background: white;
        display: inline-block;
        border-radius: 50%;
        animation-name: typing;
        animation-duration: 1.4s;
        animation-iteration-count: infinite;
        animation-fill-mode: both;

        &:nth-child(2) {
          animation-delay: 0.2s;
        }

        &:nth-child(3) {
          animation-delay: 0.4s;
        }
      }
    }

    .chat-message__error {
      font-size: 0.8em;
      color: $t-error;
    }
  }
  &.mine {
    @media #{$query-mobile} {
      justify-content: flex-end;
      .chat-message__content {
        align-items: flex-end;
      }
    }
    .chat-message__content {
      .chat-message__bubble {
        background: $narrojo;
      }
    }
  }

  &.sending {
    opacity: 0.5;
  }

  &.failed {
    cursor: pointer;
  }
}

@keyframes typing {
  0% {
    opacity: 0.2;
    transform: translateY(0);
  }
  20% {
    opacity: 1;
    transform: translateY(-3px);
  }
  100% {
    opacity: 0.2;
    transform: translateY(0);
  }
}
</style>
