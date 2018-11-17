<template>
	<div id="content" data-layout-type="chat" ref="conversationDiv" :class="{'renderbox' : isLoading}">
		<template v-if="!isLoading">
			<button v-if="!lastPage" @click="loadMore" class="button" data-button-size="medium" data-button-font="little" data-button-uppercase :disabled="isLoadingMore">
				{{!isLoadingMore ? 'Cargar mensajes antiguos' : 'Cargando más mensajes...'}}
			</button>
			 <div class="message" v-for="messages in messageBlocks" :key="messages">
				<avatar :avatar="getMessageUser(messages[0].user_id).avatar.small"></avatar>
				<div class="message-content">
					<strong class="username">{{getMessageUser(messages[0].user_id).name}}</strong> <small>{{$moment.utc(messages[0].created_at).local().calendar()}}</small>
					<p v-html="formatMessage(message.content)" v-for="message in messages" :key="message"></p>
				</div>
			</div>
		</template>
	</div>
</template>
<script>
import chatAPI from "../../api/conversation";
import userAPI from "../../api/user";

import avatar from "../../components/avatar";

import formatter from "../../helpers/formatter";

import _ from "lodash";

import { mapGetters } from "vuex";

export default {
  name: "ChatConversation",
  components: { avatar },
  data() {
    return {
      partner: null,
      isLoading: false,
      isLoadingMore: false,
      lastPage: false,
      oldestId: null
    };
  },
  computed: {
    ...mapGetters("chat", ["conversation", "messages", "unread_messages"]),
    messageBlocks() {
      // The message blocks array that will be returned by the function
      let messageBlocks = [];

      // The user of the current message block
      let loopCurrentUser = null;
      // The index of the current block in the messageBlocks array
      let loopCurrentIndex = -1;

      // Get the conversation messages (too lazy to type this everytime)
      const messages = this.messages ? [...this.messages].reverse() : [];

      // Initializing variable outside the for loop
      let tooNewMessage = false;

      for (var key in messages) {
        // Check if there is a previous message
        if (typeof messages[key - 1] !== "undefined") {
          // Get the timestamps
          let currentMessageTimestamp = this.$moment(
            messages[key].created_at
          ).format("X");
          let previousMessageTimestamp = this.$moment(
            messages[key - 1].created_at
          ).format("X");

          // If 5 minutes elapsed from last message, message is new enough to be put in a separate block
          tooNewMessage =
            currentMessageTimestamp - 3000 >= previousMessageTimestamp;
        }

        // If the user is different from the previous message user, or the message is new enough, put it in a separate block
        if (loopCurrentUser !== messages[key].user_id || tooNewMessage) {
          // Different index = different messages block
          loopCurrentIndex++;
          loopCurrentUser = messages[key].user_id;
        }

        if (typeof messageBlocks[loopCurrentIndex] === "undefined") {
          // If the block does not exist, create it
          messageBlocks[loopCurrentIndex] = [];
        }

        // Push the current message to the end of the block
        messageBlocks[loopCurrentIndex].push(messages[key]);
      }

      // Return the result
      return messageBlocks;
    }
  },
  methods: {
    fetch() {
      this.isLoading = true;
      chatAPI
        .getMessages(this.partner.id, { markAsRead: true })
        .then(res => {
          if (res.items.length) {
            this.oldestId = res.items[res.items.length - 1].id;
            this.$store.dispatch("chat/updateMessages", res.items);
            this.$store.dispatch(
              "chat/updateUnreadMessagesCount",
              this.unread_messages - this.conversation.unread
            );
            this.$store.dispatch(
              "chat/markConversationAsRead",
              this.conversation.id
            );
            this.scrollToBottom();
          }
          this.lastPage = res.last_page;
        })
        .catch(err => {
          this.$router.push("/chat");
        })
        .finally(() => {
          this.isLoading = false;
        });
    },
    loadMore() {
      this.isLoadingMore = true;
      chatAPI
        .getMessages(this.partner.id, {
          before: this.oldestId,
          markAsRead: true
        })
        .then(res => {
          if (res.items.length) {
            this.oldestId = res.items[res.items.length - 1].id;
            this.$store.dispatch("chat/pushMessages", res.items);
            this.$store.dispatch(
              "chat/updateUnreadMessagesCount",
              this.unread_messages - this.conversation.unread
            );
            this.$store.dispatch(
              "chat/markConversationAsRead",
              this.conversation.id
            );
          }
          this.lastPage = res.last_page;
        })
        .finally(() => {
          this.isLoadingMore = false;
        });
    },
    getMessageUser(id) {
      /**
       * As messages only contain the user's id (to prevent eager loading of the user for each message, or
       * delivering unconventional responses in order to provide user's data, decreasing the API's performance)
       * we need to determine wich user is the id from
       */
      if (id === this.$store.getters.user.id) {
        return this.$store.getters.user;
      } else {
        return this.partner;
      }
    },
    formatMessage(content) {
      return formatter.format(content, true);
    },
    scrollToBottom() {
      this.$refs.conversationDiv.scrollTop = this.$refs.conversationDiv.scrollHeight;
    }
  },
  created() {
    this.$store.dispatch("chat/newMessage", false);
    this.partner = this.conversation.user;
    if (!this.conversation.draft) {
      this.fetch();
    }
    this.$root.$on("chat/scrollToBottom", () => {
      this.$nextTick(() => {
        this.scrollToBottom();
      });
    });
  },
  beforeDestroy() {
    this.$store.dispatch("chat/updateConversation", null);
    this.$store.dispatch("chat/updateMessages", null);
  },
  watch: {
    conversation() {
      this.partner = this.conversation.user;
      this.fetch();
    },
    messageBlocks() {
      this.$nextTick(() => {
        this.scrollToBottom();
      });
    }
  }
};
</script>
