<template>
  <div class="ban-user-modal">
    <form>
      <p>Motivo de la suspension:</p>
      <template v-for="(reason_text, index) in reasons">
        <div class="_line" :key="index">
          <label>
            <input v-model="radio_reason" type="radio" :value="reason_text">
            <span>{{reason_text}}</span>
          </label>
        </div>
      </template>
      <div class="_line">
        <label>
          <input v-model="radio_reason" type="radio" value="other">
          <span>Otra</span>
        </label>
      </div>
      <div v-show="show_other_reason" class="_line">
        <textarea v-model="other_reason" placeholder="Especifica el motivo de la suspension"></textarea>
      </div>
      <p>Duracion de la suspension(dias)</p>
      <div class="_line">
        <input v-model="duration" type="number" :disabled="infinite_duration">
        <input type="checkbox" v-model="infinite_duration"> Indefinida
      </div>
    </form>
    <div v-if="error" class="report-error" v-text="error"></div>
    <div class="modal-buttons">
      <button
        class="button"
        data-button-size="medium"
        data-button-font="medium"
        @click="$emit('close')"
      >Cancelar</button>
      <button
        class="button"
        data-button-size="medium"
        data-button-font="medium"
        data-button-important
        @click="handle"
      >Suspender usuario</button>
    </div>
  </div>
</template>

<script>
import axios from "axios";

export default {
  name: "BanUserModal",
  props: ["user_id"],
  data() {
    return {
      reasons: [
        "Publicar contenido pornográfico",
        "Realizar spam",
        "Publicar contenido que infringe derechos de autor",
        "Publica contenido con archivos maliciosos",
        "Realiza politica partidaria",
        "Publica representaciones sexuales de menores",
        "Crear multiples cuentas sin autorizacion",
        "No utilizar la herramienta NSFW reiteradas veces"
      ],
      radio_reason: null,
      other_reason: null,
      duration: 7,
      infinite_duration: false,
      error: null
    };
  },
  computed: {
    show_other_reason() {
      return this.radio_reason === "other";
    },
    reason() {
      if (this.radio_reason === "other") {
        return this.other_reason;
      }
      return this.radio_reason;
    },
    get_duration() {
      if (this.infinite_duration) return -1;
      return this.duration;
    }
  },
  methods: {
    async handle() {
      try {
        await axios.post(`/api/v1/moderation/ban`, {
          user_id: this.user_id,
          reason: this.reason,
          duration: this.get_duration
        });
        this.$notify({
          group: "top",
          text: `El usuario ha sido suspendido por ${this.duration}`,
          type: "success"
        });
        this.$emit("close");
      } catch (e) {
        const response = e.response;
        if (response.status && response.status === 422) {
          this.error = response.data.errors.reason[0];
        } else {
          this.error =
            "Hubo un error al procesar la suspension, por favor intenta mas tarde";
          throw e;
        }
      }
    }
  }
};
</script>

<style lang="scss">
@import "~@/../sass/base/_variables.scss";
.ban-user-modal {
  form {
    padding: 10px 20px;
  }

  p,
  ._line {
    margin-bottom: 10px;
  }

  input[type="checkbox"] {
    margin-right: 10px;
    flex-shrink: 0;
  }

  input[type="number"] {
    margin-right: 20px;
  }

  .report-error {
    color: $t-error;
    padding: 0 10px;
    font-weight: bold;
  }
}
</style>
