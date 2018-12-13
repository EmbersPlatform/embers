<template>
  <li class="emoji-picker">
    <button class="tooltip" @click="toggleEmojiPicker" ref="emojiPickerToggler">
      <emoji emoji="ok_hand" set="twitter" :size="15"></emoji>
    </button>
    <picker
      v-if="showEmojiPicker"
      set="twitter"
      @click="emojiSelected"
      :perLine="7"
      :i18n="pickerI18N"
      :custom="customEmojis"
      ref="emojiPicker"
    ></picker>
  </li>
</template>

<script>
import { Picker, Emoji } from "emoji-mart-vue";
import customEmojis from "@/lib/emotes/custom_emotes";

const pickerI18N = {
  search: "Buscar",
  notfound: "No se encontraron emojis",
  categories: {
    search: "Resultados",
    recent: "Recientes",
    custom: "Embers",
    people: "Gente",
    nature: "Animales y naturaleza",
    foods: "Comida",
    activity: "Actividades",
    places: "Lugares y viajes",
    objects: "Objetos",
    symbols: "Símbolos",
    flags: "Banderas"
  }
};

export default {
  components: { Picker, Emoji },
  data() {
    return {
      pickerI18N,
      customEmojis,
      showEmojiPicker: false
    };
  },
  methods: {
    emojiSelected(emoji) {
      this.$emit("selected", emoji);
    },
    toggleEmojiPicker() {
      this.showEmojiPicker = !this.showEmojiPicker;
      this.$root.$emit("fixed");
    }
  },

  created() {
    $(window).on("click tap", e => {
      let isPicker = !!$(e.target).parents("li.emoji-picker").length;
      if (!isPicker && this.showEmojiPicker) {
        this.showEmojiPicker = false;
        this.$root.$emit("fixed");
      }
      return;
    });
  }
};
</script>
