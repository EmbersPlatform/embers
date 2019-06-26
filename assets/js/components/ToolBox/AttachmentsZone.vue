<template>
  <div class="attachments-zone">
    <attachments-item
      v-for="(attachment, index) in ordered_attachments"
      :key="index"
      :attachment="attachment"
      @removed="remove"
      @clicked="clicked(attachment.id)"
    ></attachments-item>
    <attachments-item v-if="uploading" :placeholder="true"/>
  </div>
</template>

<script>
import _ from "lodash";
import AttachmentsItem from "./AttachmentsItem";

export default {
  name: "attachments-zone",
  components: { AttachmentsItem },
  props: {
    attachments: {
      type: Array,
      default: []
    },
    uploading: {
      type: Boolean,
      default: false
    }
  },
  computed: {
    ordered_attachments() {
      return _.orderBy(this.attachments, "timestamp", "asc");
    }
  },
  methods: {
    remove(id) {
      this.$emit("attachment-removed", id);
    },
    clicked(id) {
      this.$emit("clicked", id);
    }
  }
};
</script>
