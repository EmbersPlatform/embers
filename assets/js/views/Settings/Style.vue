<template>
  <div id="wrapper">
    <div id="style-settings" class="block" data-layout-type="column">
      <h2>Apariencia</h2>
      <article data-card-size="medium" class="card">
        <div class="card-wrapper">
          <header class="header">
            <div data-status class="avatar">
              <a class>
                <img :src="user.avatar.small" />
              </a>
            </div>
            <div class="header-content">
              <h4>
                <a class="username">{{user.username}}</a>
              </h4>
              <a class="card-date">hace unos segundos</a>
            </div>
          </header>
          <section class="card-wrapper-content big-text">
            <p class="card-body">¡Hola, mundo!</p>
          </section>
        </div>
      </article>
      <form>
        <div class="_line">
          <input
            type="radio"
            id="settings-theme-dark"
            v-model="settings.style_theme"
            value="dark"
            :checked="settings.style_theme == 'dark'"
            @click="update_theme('dark')"
          />
          <label for="settings-theme-dark">Tema oscuro</label>
        </div>
        <div class="_line">
          <input
            type="radio"
            id="settings-theme-light"
            v-model="settings.style_theme"
            value="light"
            :checked="settings.style_theme == 'light'"
            @click="update_theme('light')"
          />
          <label for="settings-theme-light">Tema claro</label>
        </div>
      </form>
    </div>
  </div>
</template>

<script>
import user from "../../api/user";

import Post from "@/components/Card/_Card";

export default {
  components: { Post },
  data: () => ({
    user: null,
    settings: {
      style_theme: "dark"
    }
  }),
  methods: {
    update_theme(theme) {
      this.settings.style_theme = theme;
      user.settings
        .updateContent(this.settings)
        .then(settings => {
          this.$store.dispatch("updateSettings", settings);
          this.$notify({
            group: "top",
            text: "¡Los cambios han sido aplicados!",
            type: "success"
          });
        })
        .finally(() => (this.loading = false));
    }
  },
  created() {
    this.user = this.$store.getters.user;
    this.settings = this.$store.getters.settings;
  }
};
</script>

<style>
#style-settings .card h4 {
  font-size: 1.2em !important;
  margin-bottom: 0 !important;
}
</style>
