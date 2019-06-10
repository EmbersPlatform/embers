<template>
  <div class="chat-message" :class="{mine: mine, sending: sending, failed: failed}" @click="retry">
    <div class="chat-message__content">
      <div class="chat-message__bubble">{{ message.text }}</div>
      <div
        v-if="failed"
        class="chat-message__error"
      >No se pudo enviar el mensaje, haz clic para volver a intentarlo.</div>
    </div>
  </div>
</template>

<script>
import axios from "axios";
import { mapGetters } from "vuex";

export default {
  name: "ChatMessage",
  props: {
    message: {
      type: Object,
      required: true
    }
  },
  computed: {
    ...mapGetters(["user"]),
    mine() {
      return this.message.sender.id == this.user.id;
    },
    optimistic() {
      return this.message.optimistic;
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
            text: this.message.text
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
    .chat-message__bubble {
      background: $blue_dark;
      color: #ffffffdd;
      padding: 5px 10px;
      border-radius: 2em;
      width: fit-content;
      float: right;
    }

    .chat-message__error {
      font-size: 0.8em;
      color: $t-error;
    }
  }
  &.mine {
    @media #{$query-mobile} {
      justify-content: flex-end;
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
</style>
