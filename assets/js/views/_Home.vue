<template>
  <div id="board">
    <div id="heading">
      <Top></Top>
    </div>
    <div id="wrapper">
      <SideModule v-if="$mq == 'lg'"></SideModule>
      <div id="content" data-layout-type="single-column">
        <ToolBox v-if="auth.loggedIn()"></ToolBox>
        <div id="home-controls">
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
import auth from "../auth";
import formatter from "@/lib/formatter";

import ToolBox from "../components/ToolBox/_ToolBox";
import Feed from "../components/Feed";
import CheckBox from "../components/inputCheckbox";
import SideModule from "../components/SideModules/Default";
import Top from "../components/Top";

import EventBus from "../lib/event_bus";

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
      new_posts: []
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
  /**
   * Triggered before this component instance is destroyed
   */
  destroyed() {
    this.$store.dispatch("cleanFeedPosts");
  }
};
</script>
