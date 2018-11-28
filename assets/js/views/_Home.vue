<template>
	<div id="board">
		<div id="heading">
			<Top></Top>
		</div>
		<div id="wrapper">
			<SideModule></SideModule>
			<div id="content" data-layout-type="single-column">
				<ToolBox v-if="auth.loggedIn()"></ToolBox>
				<div id="filtering" :class="{'open': open}">
					<div class="controls">
						<button class="filter-button" @click.prevent="refreshFeed">
							<i class="fas fa-sync-alt"></i>&nbsp;Actualizar
						</button>
					</div>
				</div>
				<Feed></Feed>
			</div>
		</div>
	</div>
</template>

<script>
import _ from "lodash";

import auth from "../auth";
import formatter from "../helpers/formatter";

import ToolBox from "../components/ToolBox/_ToolBox.vue";
import Feed from "../components/Feed.vue";
import CheckBox from "../components/inputCheckbox.vue";
import SideModule from "../components/SideModules/Default.vue";
import Top from "../components/Top.vue";

export default {
  name: "Home",
  components: {
    ToolBox,
    Feed,
    CheckBox,
    SideModule,
    Top
  },
  /**
   * Component data
   * @returns object
   */
  data() {
    return {
      auth,
      open: false
    };
  },

  methods: {
    toggleFilterControls() {
      this.open = !this.open;
    },

    refreshFeed() {
      this.$root.$emit("refresh_feed");
    }
  },
  created() {
    this.$root.$on("new_activity", () => {
      alert("new_activity");
    });
  },
  /**
   * Triggered before this component instance is destroyed
   */
  destroyed() {
    this.$store.dispatch("cleanFeedPosts");
  }
};
</script>
