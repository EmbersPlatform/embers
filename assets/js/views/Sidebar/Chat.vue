<template>
  <component :is="component"/>
</template>
<script>
import ConversationList from "@/components/Chat/ConversationList";
import HomeSidebar from "./Home";

export default {
  components: { ConversationList, HomeSidebar },
  computed: {
    component() {
      if (this.$mq == "sm") return HomeSidebar;
      return ConversationList;
    }
  }
};
</script>
