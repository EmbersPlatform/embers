<template>
  <div class="attachments-zone">
    <attachments-item
      v-for="(attachment, index) in ordered_attachments"
      :key="attachment.id"
      :attachment="attachment"
      @removed="remove"
      @clicked="clicked(index)"
    ></attachments-item>
    <attachments-item v-if="uploading" :placeholder="true"/>
  </div>
</template>

<script>
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
      return this.attachments.sort(x => x.timestamp);
    }
  },
  methods: {
    remove(id) {
      this.$emit("attachment-removed", id);
    },
    clicked(index) {
      this.$emit("clicked", index);
    }
  }
};
</script>
