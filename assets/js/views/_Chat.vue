<template>
  <div id="board">
    <div id="heading">
      <Top></Top>
    </div>
    <div id="wrapper">
      <template v-if="party_id">
        <ChatConversation :party_id="party_id" :key="$route.fullPath"/>
      </template>
      <div v-else id="content" data-layout-type="middle">
        <div id="feed">
          <h3>
            <p>Hmm. Esto está muy vacío</p>
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

import { mapGetters, mapState } from "vuex";

export default {
  name: "Chat",
  components: {
    Top,
    ChatConversation,
    NewChatModal
  },
  computed: {
    ...mapState("chat", ["show_new_chat_modal"]),
    party_id() {
      return this.$route.params.id;
    }
  }
};
</script>
