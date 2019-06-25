<template>
  <div id="secondary" v-if="auth.loggedIn()">
    <div id="secondary-sticky">
      <popular-tags/>
      <h3>anuncio</h3>
      <p>Embers se encuentra en su etapa de desarrollo alpha, algunas características del sitio podrían no funcionar correctamente. Si tienes dudas, sugerencias, o encontraste un bug, contáctanos en nuestro servidor de Discord o si te gusta lo que hacemos apoyanos en Ko-fi:</p>
      <a class="external" data-service="discord" href="https://discord.gg/uADqWPs" target="_blank">
        Unete a Embers en Discord
        <img class="emoji" src="/img/external/discord_logo.svg">
      </a>
      <a class="external" data-service="ko-fi" href="https://ko-fi.com/A1482YS9" target="_blank">
        <img class="emoji" src="/img/external/ko-fi.svg" alt="Buy Me a Coffee at ko-fi.com">
        Buy me a ko-fi
      </a>
      <div class="made-with">
        <p class="centered" v-html="madeWithText"></p>
      </div>
      <p class="centered">
        <router-link to="/rules">Reglas</router-link>·
        <router-link to="/faq">FAQ</router-link>·
        <router-link to="/acknowledgment">Agradecimientos</router-link>
        ©Embers 1{{$moment().format('YYYY')}}
      </p>
    </div>
  </div>
</template>

<script>
import auth from "../../auth";
import formatter from "@/lib/formatter";

import PopularTags from "@/components/Tag/Popular";

export default {
  components: { PopularTags },
  computed: {
    madeWithText() {
      return formatter.format("Hecho con :w_coffeecup: y mucho :w_heart:");
    }
  },

  /**
   * Component data
   * @returns object
   */
  data() {
    return { auth };
  }
};
</script>
