<template>
	<div class="block" data-layout-type="form">
    <template v-if="can_show_account_created_message">
      <p>Tu cuenta ha sido creada, hemos enviado un enlace para activar tu cuenta a tu correo electrónico. Podrás iniciar sesión una vez la hayas activado.</p>
    </template>
    <template v-else>
      <h3>Registrarse</h3>
      <form @submit.prevent="onSubmit">
        <VueRecaptcha v-if="!skipRecaptcha" ref="invisibleRecaptcha" @verify="onVerify" @expired="onExpired" size="invisible" :sitekey="recaptchaPublicKey"></VueRecaptcha>
        <div class="error" v-if="errors.error">{{errors.error}}</div>
        <div class="error" v-for="error in errors.recaptcha_errors" :key="error">{{error}}</div>
        <label :data-error="errors.username">
          {{errors.username ? errors.username[0] : 'Nombre de usuario'}}
        </label>
        <input v-model="username" type="text" placeholder="nombre_de_usuario1" :data-error="errors.name" autocomplete="username">
        <label :data-error="errors.email">
          {{errors.email ? errors.email[0] : 'Correo electrónico'}}
        </label>
        <input v-model="email" type="email" placeholder="micorreo@proveedor.dominio" :data-error="errors.email" autocomplete="email">
        <label :data-error="errors.password">
          {{errors.password ? errors.password[0] : 'Contraseña'}}
        </label>
        <input v-model="password" type="password" placeholder="mi clave secreta" :data-error="errors.password" autocomplete="new-password">
        <label :data-error="errors.password_confirmation">
          {{errors.password_confirmation ? errors.password_confirmation[0] : 'Confirmar contraseña'}}
        </label>
        <input v-model="password_confirmation" type="password"  placeholder="mi clave secreta de nuevo" autocomplete="new-password confirmation">
        <button type="submit" :disabled="verifying" class="button" data-button-size="big" data-button-font="medium" data-button-uppercase data-button-important>
          {{verifying ? 'Verificando...' : '¡Registrarme!'}}
        </button>
      </form>
    </template>
	</div>
</template>

<script>
import auth from "../api/auth";
import axios from "axios";

import VueRecaptcha from "vue-recaptcha";
import { recaptchaPublicKey, skipRecaptcha } from "../config";

export default {
  name: "Register",
  components: { VueRecaptcha },
  methods: {
    /**
     * Triggered when reCAPTCHA has verified the user is, indeed, human
     */
    onVerify(verification) {
      this.verifying = false;

      this.register(verification);
    },

    register(verification = null) {
      this.$modal.show("rules-modal", {
        confirm: () => {
          auth
            .register({
              username: this.username,
              email: this.email,
              password: this.password,
              password_confirmation: this.password_confirmation,
              "g-recaptcha-response": verification
            })
            .then(res => (this.can_show_account_created_message = true))
            .catch(err => (this.errors = err.res.error));
        }
      });
    },

    /**
     * Triggered when reCAPTCHA token expires
     */
    onExpired() {
      this.verifying = false;
      this.$refs.invisibleRecaptcha.reset();
    },

    /**
     * Attempt user registration
     */
    onSubmit() {
      this.errors = {};
      if (
        this.username &&
        this.email &&
        this.password &&
        this.password_confirmation
      ) {
        if (this.skipRecaptcha) {
          this.register();
        } else {
          this.$refs.invisibleRecaptcha.reset();
          this.verifying = true;
          this.$refs.invisibleRecaptcha.execute();
        }
      } else {
        this.errors.error = "Debes rellenar todos los campos";
      }
    }
  },

  /**
   * Component data
   */
  data() {
    return {
      username: "",
      email: "",
      password: "",
      password_confirmation: "",
      loading: false,
      verifying: false,
      errors: {},
      skipRecaptcha: skipRecaptcha,
      recaptchaPublicKey: recaptchaPublicKey,
      can_show_account_created_message: false
    };
  },

  /**
   * Triggered when an instance of this component is created
   */
  created() {
    if (!this.skipRecaptcha) {
      let script = document.createElement("script");
      script.src =
        "//www.google.com/recaptcha/api.js?onload=vueRecaptchaApiLoaded&render=explicit";
      script.async = true;
      script.defer = true;
      document.body.appendChild(script);
    }
  }
};
</script>
