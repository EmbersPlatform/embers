<template>
  <div id="board">
    <div id="heading">
      <Top></Top>
    </div>
    <div id="wrapper">
      <SideModule v-if="$mq == 'lg'"></SideModule>
      <div id="content" data-layout-type="single-column">
        <ToolBox v-if="auth.loggedIn()" @created="handle_new_post"></ToolBox>
        <Feed></Feed>
      </div>
    </div>
  </div>
</template>

<script>
import axios from "axios";
import auth from "../auth";
import formatter from "@/lib/formatter";
import { concat_post } from "@/lib/posts";

import Intersector from "@/components/Intersector";
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
    Top,
    Intersector
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

  methods: {
    handle_new_post(new_post) {
      this.$root.$emit("addFeedPost", new_post);
    }
  }
};
</script>
