<template>
  <div class="multimedia">
    <div @click.prevent="togglePlay" class="media audio">
      <img :src="avatar">
      <hr role="progressbar" v-if="playing" :style="'width:'+progress+'%'">
      <button class="toggle">
        {{c_time}}
        <i v-if="!playing" class="fas fa-play" title="Reproducir"></i>
        <i v-else class="fas fa-stop" title="Detener"></i>
        {{c_duration}}
      </button>
      <audio ref="audio" class="hidden" @timeupdate="onTimeUpdate" @ended="ended" :volume="volume">
        <source :src="url" type="video/webm">
      </audio>
    </div>
  </div>
</template>
<script>
export default {
  name: "AudioPlayer",
  props: ["url", "avatar"],
  components: {},
  data() {
    return {
      loading: true,
      loaded: false,
      playing: false,
      paused: false,
      currentTime: 0.0,
      duration: 0.0,
      progress: 0,
      volume: 1
    };
  },
  computed: {
    c_time() {
      var mind = this.currentTime % (60 * 60);
      var minutes = Math.floor(mind / 60);

      var secd = mind % 60;
      var seconds = Math.ceil(secd);

      return minutes + ":" + ("0" + seconds).slice(-2);
    },
    c_duration() {
      var mind = this.duration % (60 * 60);
      var minutes = Math.floor(mind / 60);

      var secd = mind % 60;
      var seconds = Math.ceil(secd);

      return minutes + ":" + ("0" + seconds).slice(-2);
    }
  },
  methods: {
    onTimeUpdate(e) {
      this.currentTime = e.target.currentTime;
      this.progress = (this.currentTime * 100) / this.duration;
      if (this.currentTime >= this.duration) {
        this.duration = this.currentTime;
        this.progress = 0;
      }
    },
    ended() {
      if (!this.loaded) this.loaded = true;
      this.stop();
    },
    play() {
      this.playing = true;
      this.paused = false;
      this.$refs.audio.play();
    },
    stop() {
      this.playing = false;
      this.paused = false;
      this.$refs.audio.pause();
      this.$refs.audio.currentTime = 0;
    },
    pause() {
      this.paused = true;
      this.$refs.audio.pause();
    },
    togglePlay() {
      if (this.playing) {
        this.stop();
      } else {
        this.play();
      }
    }
  }
};
</script>
