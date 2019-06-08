<template>
  <progress class="progress tool" :value="instant" max="100">{{instant}}</progress>
</template>
<script>
export default {
  name: "SoundMeter",
  props: ["stream"],
  data() {
    return {
      context: null,
      instant: 0.0,
      slow: 0.0,
      clip: 0.0,
      script: null,
      mic: null,
      interval: null
    };
  },
  methods: {
    connectToSource(callback) {
      try {
        this.mic = this.context.createMediaStreamSource(this.stream);
        this.mic.connect(this.script);
        // necessary to make sample run, but should not be.
        this.script.connect(this.context.destination);
        if (typeof callback !== "undefined") {
          callback(null);
        }
      } catch (e) {
        console.error(e);
        if (typeof callback !== "undefined") {
          callback(e);
        }
      }
    },
    stop() {
      this.mic.disconnect();
      this.script.disconnect();
      clearInterval(this.interval);
    }
  },
  created() {
    var context = new AudioContext();
    this.context = context;
    this.instant = 0.0;
    this.slow = 0.0;
    this.clip = 0.0;
    this.script = context.createScriptProcessor(2048, 1, 1);
    this.script.onaudioprocess = event => {
      var input = event.inputBuffer.getChannelData(0);
      var i;
      var sum = 0.0;
      var clipcount = 0;
      for (i = 0; i < input.length; ++i) {
        sum += input[i] * input[i];
        if (Math.abs(input[i]) > 0.99) {
          clipcount += 1;
        }
      }
      this.instant = Math.sqrt(sum / input.length) * 100;
      this.slow = 0.95 * this.slow + 0.05 * this.instant;
      this.clip = clipcount / input.length;
    };
  },
  beforeDestroy() {
    this.stop();
  }
};
</script>
