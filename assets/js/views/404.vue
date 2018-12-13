<template>
  <div class="block" data-layout-type="wide">
    <h1 class="no-results" v-html="body"></h1>
  </div>
</template>
<script>
import formatter from "@/lib/formatter";
export default {
  computed: {
    body() {
      return formatter.format("La pagina que buscas no existe :turtle:");
    }
  }
};
</script>