<template>
  <div
    class="block"
    data-layout-type="column"
    v-html="compiledFaq"
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
      compiledFaq: null
    };
  },
  /**
   * Triggered when component is created
   */
  created() {
    axios.get("/static/faq").then(res => {
      this.compiledFaq = new MarkdownIt().render(res.data);
      this.loading = false;
    });
  }
};
</script>
