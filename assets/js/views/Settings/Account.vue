<template>
  <div id="wrapper" class="profile-settings">
    <div class="secondary">
      <div class="uploading-overlay" v-if="uploading_avatar"></div>
      <div class="avatar-wrapper" v-if="!cropping_avatar">
        <div class="change-avatar-button" @click="select_image">
          <i class="fas fa-upload"></i>
        </div>
        <avatar data-size="wide" :avatar="$store.getters.user.avatar.big"></avatar>
      </div>
      <vue-croppie
        v-if="cropping_avatar"
        ref="cropper"
        :enableResize="false"
        :viewport="{ width: 256, height: 256, type: 'circle'}"
        :boundary="{ width: 256, height: 256 }"
      />
      <div class="cropping-actions" v-if="cropping_avatar">
        <button
          :disabled="uploading_avatar"
          class="button"
          @click="cancel_cropping"
          data-button-size="medium"
          data-button-text="medium"
        >Cancelar</button>
        <button
          :disabled="uploading_avatar"
          class="button"
          @click="confirm_cropping"
          data-button-important
          data-button-size="medium"
          data-button-text="medium"
        >Guardar</button>
      </div>
      <form class="hidden" id="avatar-upload" method="post" enctype="multipart/form-data">
        <input type="file" name="avatar" ref="avatar_input" @change="avatar_selected" />
      </form>
    </div>
    <div class="block" data-layout-type="column">
      <form>
        <label>Nombre de usuario</label>
        <input type="text" :value="$store.getters.user.username" autocomplete="username" readonly />
        <label>Correo electrónico</label>
        <input id="email" type="email" v-model="email" autocomplete="email" readonly />
        <label>Mensaje de perfil</label>
        <textarea
          name="bio"
          id="bio"
          v-model="bio"
          class="form-control"
          placeholder="¡Di algo sobre ti!"
          data-autoresize
        ></textarea>
        <button
          :disabled="loading"
          @click.prevent="update()"
          class="button"
          data-button-size="big"
          data-button-font="medium"
          data-button-uppercase
          data-button-important
        >{{loading ? 'Guardando...' : 'Guardar cambios'}}</button>
      </form>
    </div>
  </div>
</template>

<script>
import user from "@/api/user";
import { blob_to_base64 } from "@/lib/blob_utils";

import avatar from "@/components/Avatar";

export default {
  components: { avatar },
  methods: {
    /**
     * Update user information
     */
    update() {
      this.loading = true;
      user.settings
        .updateProfile({ email: this.email, bio: this.bio })
        .then(res => {
          // this.$store.dispatch("updateUser", res);
          this.$notify({
            group: "top",
            text: "¡Los cambios en tu perfil han sido aplicados!",
            type: "success"
          });
        })
        .finally(() => (this.loading = false));
    },
    async avatar_selected() {
      const file = this.$refs.avatar_input.files[0];

      this.cropped_avatar_url = await blob_to_base64(file);
      this.cropping_avatar = true;
      this.$nextTick(() => {
        this.$refs.cropper.bind({
          url: this.cropped_avatar_url
        });
      });
    },
    confirm_cropping() {
      this.uploading_avatar = true;
      let options = {
        type: "blob",
        format: "png",
        size: { width: 256, height: 256 }
      };
      this.$refs.cropper.result(options, file => {
        let form_data = new FormData();
        form_data.append("avatar", file, "cover.png");
        this.uploading = true;
        user.settings
          .updateAvatar(form_data)
          .then(avatar => (this.$store.getters.user.avatar = avatar))
          .finally(() => {
            this.uploading_avatar = false;
            this.cancel_cropping();
          });
      });
    },
    cancel_cropping() {
      this.cropping_avatar = false;
      this.cropped_avatar_url = null;
    },

    /**
     * Simulates click over an invisible "Browse..." button
     */
    select_image() {
      this.$refs.avatar_input.click();
    }
  },

  /**
   * Component data
   * @returns object
   */
  data() {
    return {
      email: "",
      bio: "",
      loading: false,
      uploading_avatar: false,
      cropping_avatar: false,
      cropped_avatar_url: null
    };
  },

  /**
   * Triggered when a component instance is created
   */
  created() {
    this.email = this.$store.getters.user.email;
    this.bio = this.$store.getters.user.bio;
  }
};
</script>

<style lang="scss">
@import "~@/../sass/base/_variables.scss";

.profile-settings {
  .cr-viewport {
    box-shadow: 0 0 2000px 2000px rgba(0, 0, 0, 0.5) !important;
  }
  .croppie-container {
    height: auto;
  }

  .secondary {
    display: flex;
    flex-direction: column;
    justify-content: center;
    width: 30%;
    justify-content: flex-start;
    align-items: center;
    height: fit-content;
    margin: 0 20px;
    margin-bottom: 20px;
    padding: 20px 0;
    @media #{$query-mobile} {
      width: 100%;
    }
  }
  .avatar-wrapper {
    margin-bottom: 20px;
    border-radius: 50%;
    &:hover {
      .change-avatar-button {
        visibility: visible;
      }
    }
  }
  .avatar {
    width: 256px;
    height: 256px;
    margin: 0;
  }

  .change-avatar-button {
    display: flex;
    justify-content: center;
    align-items: center;
    position: absolute;
    top: 0;
    left: 50%;
    transform: translateX(-50%);
    width: 256px;
    height: 256px;
    border-radius: 50%;
    cursor: pointer;
    background: rgba(0, 0, 0, 0.5);
    color: #fff;
    font-size: 3em;
    z-index: 1;
    visibility: hidden;
  }
  .uploading-overlay {
    position: absolute;
    left: 0;
    top: 0;
    width: 100%;
    height: 100%;
    background: #0007;
    box-shadow: 0 1px 20px #0007 !important;
    z-index: 2;
    border-radius: 20px;
  }
  .cropping-actions {
    display: flex;
    justify-content: center;
    .button:not(:last-child) {
      margin-right: 10px;
    }
  }
}
</style>

