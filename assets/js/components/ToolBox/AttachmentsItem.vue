<template>
  <div v-if="placeholder" class="attachment attachment--placeholder">
    <i class="fas fa-circle-notch"></i>
  </div>
  <div
    v-else
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
  props: ["attachment", "placeholder"],
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
@import "~@/../sass/base/_variables.scss";

.attachment {
  position: relative;
  border-radius: 5px;
  border: 2px solid #050506;
  background-size: cover;
  background-position: center;
  width: 100px;
  height: 100px;
  margin-top: 10px;

  &:first-child {
    margin-left: 10px;
  }
  &:last-child {
    margin-right: 10px;
  }

  @media #{$query-mobile} {
    width: 50%;
    height: 150px;
    box-sizing: border-box;
    margin: 5px 0;

    &:first-child {
      margin-left: 0;
    }
    &:last-child {
      margin-right: 0;
    }

    .remove_attachment {
      width: 2em !important;
      height: 2em !important;
      font-size: 1.2em !important;
      border-radius: 50% !important;
      line-height: 1.8em !important;
      border: 2px solid #ffffffcc;
      box-sizing: border-box;
      right: 5px !important;
      top: 5px !important;
    }
  }

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

    @media #{$query-mobile} {
      visibility: visible;
      opacity: 1 !important;
    }

    &:hover {
      opacity: 1;
    }
  }
  &:hover .remove_attachment {
    visibility: visible;
  }
}

.attachment--placeholder {
  overflow: hidden;
  padding: 31px;
  box-sizing: border-box;
  i {
    color: #ffffffbb;
    font-size: 30px;
    animation: spin;
    animation-duration: 1000ms;
    animation-iteration-count: infinite;
    animation-timing-function: linear;
  }
}

@-moz-keyframes spin {
  from {
    -moz-transform: rotate(0deg);
  }
  to {
    -moz-transform: rotate(360deg);
  }
}
@-webkit-keyframes spin {
  from {
    -webkit-transform: rotate(0deg);
  }
  to {
    -webkit-transform: rotate(360deg);
  }
}
@keyframes spin {
  from {
    transform: rotate(0deg);
  }
  to {
    transform: rotate(360deg);
  }
}
</style>
