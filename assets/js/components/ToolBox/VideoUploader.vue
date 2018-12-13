<template>
  <div
    class="url-uploader tool"
    :class="{'renderbox' : !askForUrl}"
    data-renderbox-message="Verificando la fuente..."
  >
    <template v-if="askForUrl">
      <div class="supported">
        <i class="fab fa-youtube"></i>
        <i class="fab fa-vimeo-v"></i>
        <i class="fa-">d</i>
      </div>
      <form class="importer" @submit.prevent="importVideo">
        <label>No olvides presionar "enter" para importar</label>
        <input type="url" v-model="url" placeholder="URL del vídeo">
      </form>
    </template>
  </div>
</template>

<script>
/**
 * Import utilities
 */
import attachment from "../../api/attachment";
import notifications from "../../notifications";

/**
 * Import additional components
 */
function initialData() {
  return {
    url: null,
    uploading: false,
    stage: "ask-for-url"
  };
}
export default {
  name: "VideoUplaoder",
  props: ["show"],
  data: initialData,
  computed: {
    askForUrl() {
      return this.stage == "ask-for-url";
    },
    showLoader() {
      return this.stage == "uploading";
    }
  },
  methods: {
    resetData() {
      Object.assign(this.$data, initialData());
    },
    promptUrl() {
      this.stage = "ask-for-url";
    },
    importVideo() {
      this.uploading = true;
      this.stage = "uploading";

      attachment
        .parse(this.url)
        .then(res => {
          if (this._inactive) return;
          this.$emit("uploaded", res);
        })
        .catch(err => {
          if (this._inactive) return;
          notifications.error(err);
          this.url = null;
          this.stage = "ask-for-url";
        })
        .finally(() => {
          this.uploading = false;
        });
    }
  },
  watch: {
    show() {
      this.resetData();
    }
  }
};
</script>
