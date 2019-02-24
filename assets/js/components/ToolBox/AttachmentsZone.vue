<template>
  <div class="attachments-zone tool">
    <attachments-item
      v-for="(attachment, index) in attachments"
      :key="attachment.id"
      :attachment="attachment"
      @removed="remove"
      @clicked="clicked(index)"
    ></attachments-item>
  </div>
</template>

<script>
import AttachmentsItem from "./AttachmentsItem";
export default {
  name: "attachments-zone",
  components: { AttachmentsItem },
  props: ["attachments"],
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
