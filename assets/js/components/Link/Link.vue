<template>
  <div v-if="link.embed.type == 'image'" class="multimedia">
    <div class="media-zone">
      <media-item :medias="[image_media]" @clicked="image_clicked" />
    </div>
  </div>
  <a v-else class="link-item" :href="link.url" target="_blank">
    <div v-if="link.embed.html" class="link-item__oembed" v-html="link.embed.html"></div>
    <div v-else class="link-item__thumbnail">
      <img :src="link.embed.thumbnail_url" />
    </div>
    <div class="link-item__details">
      <p class="link-item__title" v-if="link.embed.title" v-text="title" />
      <p class="link-item__description" v-if="link.embed.description" v-text="description" />
      <p v-if="link.embed.price" class="link-item__price" v-text="link.embed.price"></p>
      <p class="link-item__url" v-text="url"></p>
    </div>
  </a>
</template>

<script>
import ellipsize from "ellipsize";
import MediaItem from "@/components/Media/MediaZone";

export default {
  name: "Link",
  components: { MediaItem },
  props: {
    link: {
      type: Object,
      required: true
    }
  },
  computed: {
    title() {
      return ellipsize(this.link.embed.title, 80);
    },
    description() {
      return ellipsize(this.link.embed.description, 200);
    },
    url() {
      return ellipsize(this.link.url, 60);
    },
    image_media() {
      if (this.link.embed.type == "image") {
        const link = this.link;
        return {
          id: link.id,
          url: link.url,
          type: "image",
          metadata: {
            preview_url: link.url
          }
        };
      }
    }
  },
  methods: {
    image_clicked(id) {
      this.$emit("clicked", id);
    }
  }
};
</script>

<style lang="scss">
@import "~@/../sass/base/_mixins.scss";
@import "~@/../sass/base/_variables.scss";

.link-item {
  display: flex;
  flex-direction: column;
  justify-content: center;
  color: #ffffffdd;
}

.link-item__thumbnail {
  padding: 0 20px;
  text-align: center;

  img {
    border-radius: 2px;
    max-width: 100%;
    max-height: 400px;
  }
  z-index: 2;
}

.link-item__oembed {
  text-align: center;
  z-index: 2;

  @media #{$query-mobile} {
    padding: 0;
  }
}
[data-card-size="little"] .link-item__oembed iframe {
    max-height: 200px;
}

.link-item__title {
  color: $narrojo !important;
  font-weight: bold !important;
  margin-bottom: 10px;
  overflow: hidden;
  max-height: 3.8em;
  overflow: hidden;
}

.link-item__description {
  max-height: 3.6em;
  overflow: hidden;
}

.link-item__details {
  padding: 10px 20px;
  border-radius: 2px;
}

.link-item__price {
  color: $greentext !important;
}

.link-item__url {
  text-decoration: underline;
  margin-top: 5px;
  max-height: 1.4em;
  overflow: hidden;
}
</style>
