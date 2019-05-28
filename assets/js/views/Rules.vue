<template>
  <div
    class="block"
    data-layout-type="column"
    v-html="compiledRules"
    :class="{'renderbox' : loading}"
  ></div>
</template>

<script>
import axios from "axios";
import MarkdownIt from "markdown-it";
export default {
  /**
   * Component data
   * @returns object
   */
  data() {
    return {
      loading: true,
      compiledRules: null
    };
  },
  /**
   * Triggered when component is created
   */
  created() {
    axios.get("/static/rules").then(res => {
      this.compiledRules = new MarkdownIt().render(res.data);
      this.loading = false;
    });
  }
};
</script>
