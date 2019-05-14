<template>
  <nav id="top">
    <input
      id="search"
      type="text"
      placeholder="Buscar en Embers"
      v-model="searchParams"
      @keyup.enter="search"
    >
  </nav>
</template>
<script>
export default {
  data() {
    return {
      searchParams: ""
    };
  },
  computed: {
    url_array() {
      var array = this.$route.fullPath.replace("#", "/");
      if (array.substring(0, 1) == "/") {
        array = array.substring(1);
      }
      return array.split("/");
    },
    breadcrumbs() {
      var crumbs = '<li><a href="/">home</a></li>';
      if (this.$route.fullPath == "/") {
        return crumbs;
      }
      for (var i = 0; i < this.url_array.length; i++) {
        //convierte los valores almacenados en breadcrumbs en codigo html
        crumbs += '&rsaquo;<li><a href="/';
        for (var o = 0; o < i; o++) {
          crumbs += this.url_array[o] + "/";
        }
        crumbs +=
          this.url_array[i] +
          '">' +
          this.url_array[i].replace("@", "") +
          "</a></li>";
      }
      return crumbs;
    }
  },
  methods: {
    search() {
      var searchParams = encodeURIComponent(this.searchParams);
      this.$router.push("/search/" + searchParams);
      this.$root.$emit("search", searchParams);
    }
  },
  created() {
    this.searchParams = this.$route.params.searchParams;
    this.$root.$on("search-update", params => {
      this.searchParams = params;
    });
  }
};
</script>
