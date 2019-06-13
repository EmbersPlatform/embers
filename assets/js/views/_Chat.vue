<template>
  <div id="board">
    <div id="wrapper">
      <template v-if="party_id">
        <ChatConversation :party_id="party_id" :key="$route.fullPath"/>
      </template>
      <div v-else id="content" data-layout-type="middle">
        <div id="feed">
          <ConversationList v-if="$mq == 'sm'"/>
          <h3 v-else>
            <p>Hmm. Esto esta muy vacio.</p>
          </h3>
        </div>
      </div>
    </div>
    <NewChatModal v-if="show_new_chat_modal"></NewChatModal>
  </div>
</template>
<script>
import axios from "axios";

import Top from "../components/Top";
import ChatConversation from "./Chat/ChatConversation";
import NewChatModal from "./Chat/NewChatModal";
import ConversationList from "@/components/Chat/ConversationList";

import { mapGetters, mapState } from "vuex";

export default {
  name: "Chat",
  components: {
    Top,
    ChatConversation,
    NewChatModal,
    ConversationList
  },
  computed: {
    ...mapState("chat", ["show_new_chat_modal"]),
    party_id() {
      return this.$route.params.id;
    }
  }
};
</script>

<style lang="scss" scoped>
#wrapper {
  padding-bottom: 0 !important;
}
</style>

<style lang="scss">
#feed {
  width: 100%;
  #column {
    width: 100%;
    padding: 10px;
    height: 100%;
  }
  .nav_ h2 {
    display: none !important;
  }
}
</style>

