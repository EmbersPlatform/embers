<template>
  <div
    class="attachment"
    :style="{'background-image': `url(${attachment.metadata.preview_url})`}"
    @click="clicked"
  >
    <span class="remove_attachment" @click="remove()" ref="remove_button">
      <i class="fa fa-times"></i>
    </span>
    <span class="type video" title="Video" v-if="attachment.type == 'video'">
      <i class="fas fa-play"></i>
    </span>
    <span class="type gif" title="GIF" v-if="attachment.type == 'gif'">GIF</span>
  </div>
</template>

<script>
export default {
  name: "attachments-item",
  props: ["attachment"],
  methods: {
    remove() {
      this.$emit("removed", this.attachment.id);
    },
    clicked(ev) {
      console.log(ev.target, this.$refs.remove_button);
      if (
        ev.target != this.$refs.remove_button &&
        !this.$refs.remove_button.contains(ev.target)
      )
        this.$emit("clicked", ev);
    }
  }
};
</script>

<style lang="scss" scoped>
.attachment {
  position: relative;
  border-radius: 5px;
  border: 2px solid #050506;
  background-size: cover;
  background-position: center;
  width: 100px;
  height: 100px;

  span.type {
    position: absolute;
    bottom: 0;
    right: 0;
    border: 1px solid #fff;
    border-radius: 5px;
    color: #fff;
    font-size: 0.7em;
    padding: 4px 8px;
    margin: 0 3px 3px 0;

    &.gif {
      font-weight: bold;
      letter-spacing: 0.2em;
      padding: 4px 5px;
    }
  }

  .remove_attachment {
    opacity: 0.7;
    visibility: hidden;
    cursor: pointer;
    position: absolute;
    top: 2px;
    right: 2px;
    color: white;
    font-size: 1rem;
    visibility: hidden;
    background: #eb3d2d;
    padding: 1px;
    width: 1.2em;
    height: 1.2em;
    box-sizing: border-box;
    display: block;
    text-align: center;
    border-radius: 2px;

    &:hover {
      opacity: 1;
    }
  }
  &:hover .remove_attachment {
    visibility: visible;
  }
}
</style>
