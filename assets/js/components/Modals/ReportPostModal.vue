<template>
  <div class="report-post-modal">
    <form>
      <p>Seleccione la razón por la que reporta el post:</p>
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
      <div class="_line">
        <textarea
          v-show="radio_reason === 'other'"
          v-model="other_reason"
          placeholder="Especifica el motivo del reporte"
        ></textarea>
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
      >Enviar reporte</button>
    </div>
  </div>
</template>

<script>
import axios from "axios";

export default {
  name: "ReportPostModal",
  props: ["post_id"],
  data() {
    return {
      reasons: [
        "Contenido pornográfico",
        "Gore",
        "Representacion sexual de un/a menor de edad",
        "Viola derechos de autor",
        "Viola leyes locales según se describe en las Reglas"
      ],
      radio_reason: null,
      other_reason: null,
      error: null
    };
  },
  computed: {
    reason() {
      if (this.radio_reason === "other") {
        return this.other_reason;
      }
      return this.radio_reason;
    }
  },
  methods: {
    async handle() {
      try {
        await axios.post(`/api/v1/posts/${this.post_id}/report`, {
          comments: this.reason
        });
        this.$notify({
          group: "top",
          text: "Tu reporte ha sido enviado. ¡Gracias!",
          type: "success"
        });
        this.$emit("close");
      } catch (e) {
        const response = e.response;
        if (response.status === 422) {
          this.error = response.data.errors.comments[0];
        } else {
          this.error =
            "Hubo un error al procesar el reporte, por favor intente mas tarde";
          throw e;
        }
      }
    }
  }
};
</script>

<style lang="scss">
@import "~@/../sass/base/_variables.scss";
.report-post-modal {
  form {
    padding: 10px 20px;
  }

  p,
  ._line {
    margin-bottom: 10px;
  }

  .report-error {
    color: $t-error;
    padding: 0 10px;
    font-weight: bold;
  }
}
</style>
