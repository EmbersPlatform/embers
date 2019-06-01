<template>
  <div class="multimedia">
    <div @click="play" class="media video" :data-title="[(!playing) ? title : '']">
      <template v-if="!playing">
        <img :src="video.metadata.image">
        <button class="toggle">
          <i class="fas fa-play" title="Reproducir"></i>
        </button>
      </template>
      <template v-else>
        <iframe
          v-if="!showDefaultEmbed"
          :src="embed.url"
          :width="embed.width"
          :height="embed.height"
          frameborder="0"
          allow="autoplay"
          webkitallowfullscreen
          mozallowfullscreen
          allowfullscreen
        ></iframe>
        <video
          v-else
          class="media video-embed-custom"
          :width="video.metadata.width"
          :height="video.metadata.height"
          controls
          autoplay="true"
        >
          <source :src="video.metadata.embed_url">
        </video>
      </template>
    </div>
    <a :href="video.url" class="source" target="_blank">
      <div class="media title" target="_blank" v-if="hasTitle">{{ title }}</div>
      <div class="media description" target="_blank" v-if="hasDescription">{{ description }}</div>
      <div class="media url" target="_blank">
        <img :src="video.metadata.provider_icon" class="media provider-icon" v-if="hasProviderIcon">
        <span>{{ url }}</span>
      </div>
    </a>
  </div>
</template>

<script>
import ellipsize from "ellipsize";

export default {
  props: ["video"],
  data() {
    return {
      playing: false,
      embed: null,
      defaults: ["http://", "https://", "ftp://", "www.", "embed/", "video/"]
    };
  },
  computed: {
    title() {
      var elem = document.createElement("textarea");
      elem.innerHTML = this.video.metadata.title;
      var decoded = elem.value;
      return decoded;
    },
    a_url() {
      var _url = this.video.url;
      for (var i = 0; i < this.defaults.length; i++) {
        _url = _url.replace(this.defaults[i], "");
      }
      return _url.split("/");
    },
    provider() {
      switch (this.a_url[0]) {
        case "youtube.com":
        case "youtu.be":
          return "youtube";
          break;
        case "vimeo.com":
          return "vimeo";
          break;
        case "facebook.com":
          return "facebook";
          break;
        case "twitter.com":
          return "twitter";
          break;
        case "dailymotion.com":
          return "dailymotion";
          break;
        case "gfycat.com":
          return "gfycat";
          break;
      }
      return false;
    },
    seeSourceUrl() {
      var url = "https://";
      switch (this.provider) {
        case "youtube":
          url += "www.youtube.com/";
          break;
        case "vimeo":
          url += "vimeo.com/";
          break;
        case "facebook":
          return this.video.url;
          break;
        case "twitter":
          return this.video.url;
          break;
        case "dailymotion":
          url += "www.dailymotion.com/video/";
          break;
        case "gfycat":
          url += "gfycat.com/";
          break;
      }
      return (url += this.a_url[1]);
    },
    seeSourceMessage() {
      this.uProvider =
        this.provider.charAt(0).toUpperCase() + this.provider.slice(1);
      if (this.provider == "dailymotion") {
        return (
          'Ver "' +
          this.title.replace(" - Dailymotion", "") +
          '" en ' +
          this.uProvider
        );
      }
      return 'Ver "' + this.title + '" en ' + this.uProvider;
    },
    hasDescription() {
      return (
        this.video.metadata.hasOwnProperty("description") &&
        this.video.metadata.description !== null
      );
    },
    hasTitle() {
      return this.video.metadata.hasOwnProperty("title");
    },
    hasProviderIcon() {
      return this.video.metadata.hasOwnProperty("provider_icon");
    },
    hasEmbedUrl() {
      return this.video.metadata.hasOwnProperty("embed_url");
    },
    showDefaultEmbed() {
      return !this.provider;
    },
    title() {
      if (!this.hasTitle) return null;
      return ellipsize(this.video.metadata.title, 80);
    },
    description() {
      if (!this.hasDescription) return null;
      return ellipsize(this.video.metadata.description, 200);
    },
    url() {
      return ellipsize(this.video.url, 60);
    }
  },
  methods: {
    play() {
      const img = $(this.$el).find("img");
      this.embed = {
        width: img.width(),
        height: img.height()
      };
      switch (this.provider) {
        case "facebook":
        case "twitter":
        case "youtube":
        case "vimeo":
        case "dailymotion":
          if (!this.hasEmbedUrl) break;
          this.embed.url = this.video.metadata.embed_url;
          this.playing = true;
          return;
          break;
      }
      this.embed.url = "https://";
      switch (this.provider) {
        case "youtube":
          if (!this.hasEmbedUrl) this.embed.url += "www.youtube.com/embed/";
          break;
        case "vimeo":
          if (!this.hasEmbedUrl) this.embed.url += "player.vimeo.com/video/";
          break;
        case "dailymotion":
          if (!this.hasEmbedUrl)
            this.embed.url += "www.dailymotion.com/embed/video/";
          break;
        case "gfycat":
          this.embed.url += "gfycat.com/ifr/";
          break;
      }
      this.embed.url += this.a_url[1] + "?autoplay=1";
      this.playing = true;
    }
  },
  created() {
    // Fallback for old videos that don't have metadata
    if (typeof this.video.metadata == "string") {
      this.video.metadata = {
        title: "",
        image: this.video.metadata
      };
    }
  }
};
</script>
