<template>
	<div id="board">
		<div id="heading">
			<Top></Top>
		</div>
		<div id="wrapper">
			<div id="content" data-layout-type="masonry">
				<Feed name="public" :filters="filters" size="little"></Feed>
			</div>
		</div>
	</div>
</template>

<script>
import auth from "../auth";
import Feed from "../components/Feed.vue";
import Top from "../components/Top.vue";
export default {
  name: "Discover",
  components: {
    Feed,
    Top
  },
  /**
   * Component data
   * @returns object
   */
  data() {
    return {
      auth
    };
  },
  computed: {
    hash: function() {
      return this.$route.hash.replace("#", "");
    },
    filters: function() {
      if (this.$route.hash && this.hash != "" && this.hash != "recent") {
        return [this.hash];
      }
      return [];
    },
    feed: function() {
      switch (this.hash) {
        case "":
        case "text":
        case "image":
        case "video":
        case "audio":
        case "link":
          return "recent";
          break;
        case "recent":
          return "public";
          break;
        default:
          //force 404
          this.$router.push({ name: "404" });
          break;
      }
    }
  },
  methods: {},

  /**
   * Triggered before this component instance is destroyed
   */
  destroyed() {
    this.$store.dispatch("cleanFeedPosts");
  }
};
</script>
