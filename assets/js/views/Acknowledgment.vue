<template>
  <div
    class="block"
    data-layout-type="column"
    v-html="compiledAcknowledgment"
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
      compiledAcknowledgment: null
    };
  },
  /**
   * Triggered when component is created
   */
  created() {
    axios.get("/static/acknowledgments").then(res => {
      this.compiledAcknowledgment = new MarkdownIt().render(res.data);
      this.loading = false;
    });
  }
};
</script>
