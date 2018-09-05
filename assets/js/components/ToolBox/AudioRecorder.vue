<template>
	<div class="audio-recorder tool" :class="{'renderbox' : isProcessing}" data-renderbox-message="Procesando sonidos...">
		<button v-if="!isProcessing" @click="toggleRecording" :class="{recording: isRecording}">
			{{(!isRecording) ? 'iniciar' : terminar}}
		</button>
	</div>
</template>

<script>
	import RecordRTC from 'recordrtc'
	import attachmentAPI from '../../api/attachment';

	export default {
		components: {},
		data () {
			return {
				isRecording: false,
				isProcessing: false,
				recorder: null,
				stream: null,
				dataUrl: ''
			};
		},
		methods: {
			startRecording () {
				navigator.getUserMedia({audio: true, video: false}, stream => {
					this.stream = stream
					this.isRecording = true;
					this.recorder = RecordRTC(this.stream, { type: 'audio' })
					this.recorder.startRecording();
				}, error => {
					alert('Unable to capture your camera. Please check console logs.');
					console.error(error);
				});
			},
			stopRecording (abort = false) {
				this.isRecording = false;
				if(abort) {
					this.isProcessing = false;
					this.stream.stop();
					return;
				}
				this.isProcessing = true;
				this.recorder.stopRecording(audioURL => {
					this.stream.src = audioURL;

					var recordedBlob = this.recorder.getBlob();
					attachmentAPI.audio.upload(recordedBlob)
					.then( data => {
						this.$emit('uploaded', data);
						this.$emit('audio-uploaded', data)
					})
					.finally( () => {
						this.isProcessing = false;
					})
					this.stream.stop();
				});
			},
			toggleRecording () {
				if(this.isRecording) {
					this.stopRecording();
				} else {
					this.startRecording();
				}
			}
		},
		beforeDestroy() {
			this.stopRecording(true);
		}
	};
</script>