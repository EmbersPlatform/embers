<template>
  <div class="ban-user-modal">
    <form>
      <p>Motivo de la suspension:</p>
        <textarea v-model="reason" placeholder="Especifica el motivo de la suspension"></textarea>
      <p>Duracion de la suspension(dias)</p>
      <div class="_line">
        <input v-model="duration" type="number" :disabled="infinite_duration">
        <input type="checkbox" v-model="infinite_duration"> Indefinida
      </div>
      <div class="_line">
        <label>Eliminar publicaciones</label>
        <select v-model="delete_since">
          <option value="" selected>No eliminar nada</option>
          <option value="1">Ultimas 24 horas</option>
          <option value="7">Ultimos 7 dias</option>
          <option value="-1">TODOS</option>
        </select>
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
      reason: null,
      duration: 7,
      delete_since: null,
      infinite_duration: false,
      error: null
    };
  },
  computed: {
    get_duration() {
      if (this.infinite_duration) return -1;
      return this.duration;
    }
  },
  methods: {
    async handle() {
      try {
        let params = {
          user_id: this.user_id,
          reason: this.reason,
          duration: this.get_duration
        }

        if(this.delete_since) {
          params.delete_content_since = this.delete_since
        }

        await axios.post(`/api/v1/moderation/ban`, params);
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
