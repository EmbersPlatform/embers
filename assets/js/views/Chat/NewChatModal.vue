<template>
  <div id="new-chat-modal" ref="modalParent">
    <div class="body">
      <form>
        <input
          v-model="search"
          type="text"
          class="new-chat-search"
          placeholder="¿Con quién quieres hablar?"
          @keydown.enter.prevent="startConversation"
          @keyup="fetch_reccomendations"
          ref="input"
        >
      </form>
      <div v-if="reccomendations" class="nav_">
        <ul>
          <li v-for="reco in reccomendations" class="n_item" :key="reco.id">
            <span
              active-class="active"
              class="n_i_wrap"
              @click.prevent="userSelected(reco.canonical)"
            >
              <avatar :avatar="reco.avatar.small"></avatar>
              <span class="n_i_w_content u_name">{{ reco.username }}</span>
            </span>
          </li>
        </ul>
      </div>
    </div>
  </div>
</template>
<script>
import axios from "axios";
import { mapGetters } from "vuex";
import avatar from "@/components/Avatar";

import _ from "lodash";

export default {
  name: "NewChatModal",
  components: { avatar },
  data() {
    return {
      search: "",
      reccomendations: []
    };
  },
  methods: {
    async fetch_reccomendations() {
      const { data: reccomendations } = await axios.get(
        `/api/v1/search_typeahead/user/${this.search}`
      );
      this.reccomendations = reccomendations;
    },
    userSelected(username) {
      this.search = username;
      this.startConversation();
    },
    startConversation() {
      this.$router.push(`/chat/${this.search}`);
      this.close();
    },
    close() {
      this.$store.dispatch("chat/toggleNewChatModal", false);
      this.$root.$emit("blurSidebar", false);
    }
  },
  mounted() {
    this.$refs.input.focus();
    $(this.$refs.modalParent).on("click tap", e => {
      let isChild = !!$(e.target).parents("div#new-chat-modal").length;
      if (!isChild) {
        // If click is issued outside user menu and outside menu's trigger
        this.close();
      }
    });
  }
};
</script>
