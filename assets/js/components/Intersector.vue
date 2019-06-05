<template>
  <div class="intersector"/>
</template>

<script>
export default {
  props: {
    options: {
      type: Object
    }
  },
  data: () => ({
    observer: null
  }),
  mounted() {
    const options = this.options || {};
    this.observer = new IntersectionObserver(([entry]) => {
      if (entry && entry.isIntersecting) {
        this.$emit("intersect");
      }
    }, options);

    this.observer.observe(this.$el);
  },
  destroyed() {
    this.observer.disconnect();
  }
};
</script>

<style lang="scss">
.intersector {
  height: 1px;
}
</style>

