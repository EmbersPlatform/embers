<template>
  <div id="wrapper">
    <div class="block" data-layout-type="column">
      <div
        class="confirm-alert"
        v-if="email_sent"
      >Te enviamos un mail con un link para cambiar tu contraseña.</div>
      <button
        class="button"
        data-button-size="big"
        data-button-font="medium"
        data-button-uppercase
        data-button-important
        :disabled="sending"
        @click="send_email"
      >Restablecer contraseña</button>
    </div>
  </div>
</template>

<script>
import axios from "axios";

export default {
  data: () => ({
    email_sent: false,
    sending: false
  }),
  methods: {
    async send_email() {
      if (this.sending) return;
      this.sending = true;
      await axios.post(`/api/v1/account/reset_pass`);
      this.email_sent = true;
      this.sending = false;
    }
  }
};
</script>
