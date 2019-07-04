<template>
  <div id="wrapper" data-layout-type="column">
    <div class="block" data-layout-type="column">
      <h2>Portada</h2>
    </div>
    <div class="block" data-layout-type="wide" ref="container">
      <div
        class="cover-preview"
        :style="`min-height: ${cropper_height}px;`"
        :class="{uploading: uploading}"
      >
        <div
          v-if="uploading"
          class="uploading-overlay"
          :style="`width: ${cropper_width}px; height: ${cropper_height}px;`"
        >Guardando...</div>
        <vue-croppie
          v-if="show_cropper"
          ref="cropper"
          :enableResize="false"
          :viewport="{ width: cropper_width, height: cropper_height }"
          :boundary="{ width: cropper_width, height: cropper_height }"
        />
        <img
          v-else
          :style="`width: ${cropper_width}px; height: ${cropper_height}px;`"
          :src="user.cover"
          @load="resize_cropper"
        />
      </div>
    </div>
    <div class="block" data-layout-type="column">
      <form id="cover-upload" method="post" enctype="multipart/form-data">
        <label>La portada se redimensionará a 960x320 píxeles.</label>
        <div class="actions">
          <button
            v-if="!show_cropper"
            :disabled="uploading"
            @click.prevent="select_image"
            class="button"
            data-button-size="big"
            data-button-font="medium"
            data-button-uppercase
            data-button-important
          >{{uploading ? 'Subiendo...' : 'Cambiar portada'}}</button>
          <template v-if="show_cropper">
            <button
              @click.prevent="cancel_cropping"
              class="button"
              data-button-size="big"
              data-button-font="medium"
              data-button-uppercase
              :disabled="uploading"
            >Cancelar</button>
            <button
              @click.prevent="upload_cover"
              class="button"
              data-button-size="big"
              data-button-font="medium"
              data-button-uppercase
              data-button-important
              :disabled="uploading"
            >Guardar portada</button>
          </template>
        </div>

        <input class="hidden" type="file" name="cover" ref="cover_input" @change="start_cropping" />
      </form>
    </div>
  </div>
</template>

<script>
import user from "../../api/user";
import _ from "lodash";

function getBase64(file) {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.readAsDataURL(file);
    reader.onload = () => resolve(reader.result);
    reader.onerror = error => reject(error);
  });
}

export default {
  components: {},
  methods: {
    async start_cropping() {
      this.show_cropper = true;
      this.cropper_image = await getBase64(this.$refs.cover_input.files[0]);
      this.resize_cropper();
    },
    resize_cropper() {
      if (this.resize_timeout) return;
      this.resize_timeout = setTimeout(() => {
        clearTimeout(this.resize_timeout);
        this.resize_timeout = null;
      }, 50);

      var parentW = this.$refs.container.offsetWidth;
      var w = parentW < 960 ? parentW : 960;
      var h = parentW < 960 ? Math.round(parentW * 0.33) : 320;
      this.cropper_width = w;
      this.cropper_height = h;
      if (this.show_cropper) {
        this.show_cropper = false;
        this.$nextTick(() => {
          this.show_cropper = true;
          this.$nextTick(() => {
            this.bind_cropper();
          });
        });
      }
    },
    bind_cropper() {
      this.$refs.cropper.bind({
        url: this.cropper_image
      });
    },

    /**
     * Simulates a click over the file input
     */
    select_image() {
      this.$refs.cover_input.click();
    },
    cancel_cropping() {
      this.show_cropper = false;
      this.cropper_image = null;
    },
    upload_cover() {
      let options = {
        type: "blob",
        format: "png",
        size: { width: 960, height: 320 }
      };
      this.$refs.cropper.result(options, file => {
        let form_data = new FormData();
        form_data.append("cover", file, "cover.png");
        this.uploading = true;
        user.settings
          .updateCover(form_data)
          .then(url => (this.$store.getters.user.cover = url))
          .finally(() => {
            this.uploading = false;
            this.show_cropper = false;
          });
      });
    }
  },

  /**
   * Component data
   * @returns object
   */
  data() {
    return {
      uploading: false,
      show_cropper: false,
      cropper_width: 960,
      cropper_height: 320,
      cropper_image: null,
      resize_timeout: null
    };
  },
  computed: {
    user() {
      return this.$store.getters.user;
    }
  },
  mounted() {
    setTimeout(this.resize_cropper, 100);
    window.addEventListener("resize", this.resize_cropper);
  },
  beforeDestroy() {
    window.removeEventListener("resize", this.resize_cropper);
  }
};
</script>

<style lang="scss">
.cr-viewport {
  border: none !important;
}
.uploading {
  .cr-slider-wrap {
    visibility: hidden;
  }
}
.block {
  width: 100%;
}
.uploading-overlay {
  position: absolute;
  top: 0;
  left: 0;
  background: #00000099;
  z-index: 2;
  display: flex;
  justify-content: center;
  align-items: center;
  font-size: 2em;
}
.cover-preview {
  & > img {
    height: initial;
  }
}
#cover-upload {
  label {
    text-align: center;
  }
  .actions {
    display: flex;
    justify-content: center;
    .button {
      width: auto;
    }
  }
}
</style>
