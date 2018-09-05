<template>
  <div class="Passes">
    <div class="Passes-title" v-if="hasInvites">
      <h3>Invitaciones</h3>
      <h5>¡Invita a tus amigos a Embers dándole uno de los links de aquí abajo!</h5>
    </div>
    <ul class="Passes-list" v-if="hasInvites">
      <li class="Passes-pass" v-for="pass in passes" @click.prevent="copyToClipboard(pass.id)">
        <span>{{pass.id}}</span> <button class="btn btn-green btn-sm"><i class="zmdi zmdi-copy"></i></button>
      </li>
    </ul>
  </div>
</template>

<script>
  import user from '../api/user';

  export default {
    data() {
      return {
        passes: {}
      }
    },
    computed: {
      hasInvites() {
        return this.passes.length;
      },
    },
    methods: {
      copyToClipboard(pass) {
        //dialogs.alert('Copia el siguiente link y dáselo a un amigo para que pueda registrarse en Embers:\n http://embers.ml/register/'+pass);
      }
    },
    created() {
      user.getPasses()
      .then(res => {
          this.passes = res;
      })
      .catch(() => {
        return;
      })
    }
  }
</script>