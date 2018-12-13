<template>
  <div class="reactions-modal">
    <div class="reactions-list">
      <div
        v-for="(data, reaction) in reactions"
        class="reaction"
        @click="selectReaction(reaction)"
        :key="reaction"
        :active="reaction == currentReaction"
      >
        <img :src="`/img/emoji/${reaction}.svg`" :alt="reaction" class="emoji">
        {{ data.total }}
      </div>
      <button
        data-button-size="medium"
        data-button-font="medium"
        class="button close-reactions-modal"
        @click="$emit('close')"
      >
        <i class="fas fa-chevron-left"></i>
      </button>
    </div>
    <div class="reactions-users">
      <div
        v-if="reactions[currentReaction].total !== users.length"
        class="hidden-reactions-notice"
      >Se han ocultado reacciones de algunos usuarios debido a sus configuraciones de privacidad.</div>
      <div class="reactions-users-list">
        <router-link
          :to="user.url"
          class="reaction-user"
          v-for="user in users"
          :key="user.id"
          @click.native="$emit('close')"
        >
          <avatar :avatar="user.avatar.small"></avatar>
          <strong>{{ user.name }}</strong>
        </router-link>
      </div>
    </div>
  </div>
</template>

<script>
import avatar from "@/components/Avatar";

export default {
  name: "ReactionsModal",
  components: { avatar },
  props: ["reactions"],
  data() {
    return {
      currentReaction: Object.keys(this.reactions)[0]
    };
  },
  computed: {
    users() {
      if (!this.currentReaction) return [];
      return this.reactions[this.currentReaction].users;
    }
  },
  methods: {
    selectReaction(reaction) {
      this.currentReaction = reaction;
    }
  }
};
</script>
