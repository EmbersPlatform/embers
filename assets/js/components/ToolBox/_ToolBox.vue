<template>
	<div class="toolbox" :class="{'tool-box-open': canShowEditor, 'renderbox': status.loading}" data-renderbox-message="Publicando...">
		<template v-if="!status.loading">
			<Editor type="toolbox" @update="updateBody" @paste="handlePaste" @focus="openEditor" :attachment="showAttachment" :class="{'compressed': !canShowEditor, 'big-text': bigTextBody}" data-editor-style="toolbox" rel="editor"></Editor>
			<div class="tags-wrapper tool" :class="{'compact':!canPublish || status.isAddingAttachment || !canShowEditor}">
				<input type="text" placeholder="Tags separados por espacios" v-model="post.tags" />
			</div>
			<div class="renderbox" data-renderbox-message="Procesando..." v-if="status.isAddingAttachment"></div>
			<template v-if="showAttachment">
				<button class="remove-attachment" @click.prevent="removeAttachment" data-tip="Quitar adjunto" data-tip-position="left" data-tip-text>
					<i class="fas fa-times"></i>
				</button>
				<VideoEmbed v-if="post.attachment.type == 'video'" :video="post.attachment" class="tool"></VideoEmbed>
				<LinkEmbed v-if="post.attachment.type == 'link'" :link="post.attachment" class="tool"></LinkEmbed>
				<AudioPlayer v-if="post.attachment.type == 'audio'" :url="post.attachment.url" class="tool"></AudioPlayer>
				<div v-if="post.attachment.type == 'image'" class="multimedia tool">
					<span class="media image">
						<img :src="post.attachment.url">
					</span>
				</div>
			</template>
			<template v-else>
				<AudioRecorder v-if="canShowAudioRecorder" @uploaded="receivedAttachment"></AudioRecorder>
			</template>
			<div class="controls tool" v-if="canShowEditor">
				<div class="m_block">
					<input-switch class="_line" value="text" v-model="post.nsfw" :checked="post.nsfw">NSFW</input-switch>
					<template v-if="!hasAttachment">
						<button v-if="" :disabled="status.isAddingAttachment || (canPublish && showAttachment)" @click.prevent="triggerUpload" class="button" data-button-size="medium" data-button-font="medium" data-tip="Subir imagen" data-tip-position="left" data-tip-text>
							<i class="far fa-image"></i>
						</button>
						<button v-if="" :disabled="status.isAddingAttachment || (canPublish && showAttachment)" @click.prevent="toggleAudioRecording" class="button" data-button-size="medium" data-button-font="medium" data-tip="Grabar audio" data-tip-position="left" data-tip-text>
							<i class="fas fa-microphone"></i>
						</button>
						<form v-if="!status.isAddingAttachment" ref="imageUploadForm" method="post" enctype="multipart/form-data" class="hidden">
							<input type="file" name="file" accept="image/*" ref="imageUploadInput" @change="uploadImage">
						</form>
					</template>
				</div>
				<div class="m_block">
					<button @click.prevent="close" class="button" data-button-size="medium" data-button-font="medium">cancelar</button>
					<button :disabled="!canPublish" @click.prevent="addPost" class="button" data-button-size="medium" data-button-font="medium" data-button-important>publicar</button>
				</div>
			</div>
		</template>
	</div>
</template>

<script>
	/**
	 * Import utilities
	 */
	import moment from 'moment';
	import helpers from '../../helpers';

	/**
	 * Import API interfaces
	 */
	import post from '../../api/post';
	import attachment from '../../api/attachment';

	/**
	 * Import PostCreator child components
	 */
	import Editor from '../Editor';
	import AudioRecorder from './AudioRecorder';

	/**
	 * Import additional components
	 */
	import Switch from '../inputSwitch.vue';

	import VideoEmbed from '../Card/VideoEmbed.vue';
	import LinkEmbed from '../Card/LinkEmbed.vue';
	import AudioPlayer from '../Card/AudioPlayer.vue';

	const initialData = function () {
		return {
			post: {
				body: null,
				nsfw: false,
				attachment: null,
				tags: '',
			},
			status: {
				open: false,
				loading: false,
				errors: null,
				isAddingAttachment: false,
				recordingAudio: false,
			}
		}
	}

	export default {
		name: 'PostCreator',
		components: {
			Editor,
			AudioRecorder,
			VideoEmbed,
			LinkEmbed,
			AudioPlayer,
			'input-switch': Switch
		},
		data: initialData,
		computed:{
			canShowEditor() {
				return this.status.open;
			},
			canShowAudioRecorder() {
				return this.canShowEditor && this.status.recordingAudio && !this.status.isAddingAttachment;
			},
			canPublish() {
				if(!this.status.isAddingAttachment){
					if(!this.post.body && !this.hasAttachment){
						return false;
					}
					return true;
				}
				return false;
			},
			hasAttachment() {
				return this.post.attachment !== null;
			},
			showAttachment() {
				if(this.hasAttachment && this.canShowEditor){
					return true;
				}
				return false;
			},
			bigTextBody() {
				return (this.post.body && this.post.body.length <= 85 && !/\r|\n/.exec(this.post.body) && !this.post.attachment);
			}
		},
		methods: {
			openEditor() {
				if(this.status.open) return;
				this.status.open = true;
				this.$root.$emit('blurToolBox', true);
			},
			close() {
				this.status.open = false;
				this.$root.$emit('blurToolBox', false);
			},
			reset() {
				Object.assign(this.$data, initialData());
				this.$emit('reset');
			},
			updateBody(body) {
				this.post.body = body;
			},
			addPost() {
				this.status.loading = true;

				let requestData = {
					body: this.post.body,
					nsfw: this.post.nsfw,
					tags: this.post.tags.split(' ')
				};

				if (this.post.attachment !== null){
					requestData.attachment = this.post.attachment;
				}
				post.create(requestData).then(res => {
					this.$store.dispatch('addFeedPost', res);
					if (res.nsfw && this.$store.getters.settings.content_nsfw === 'hide') {
						this.$notify({
							group: 'top',
							text: 'Tu post ha sido publicado, pero tus opciones de contenido no te permiten verlo. Haz click aquí para cambiarlas.',
							type: 'warning',
							data: {
								close: () => { this.$router.push('/settings/content'); }
							}
						});
					}
				})
				.finally(() => {
					this.reset();
					this.close();
				});
			},
			removeAttachment() {
				this.post.attachment = null;
				this.status.recordingAudio = false;
			},
			receivedAttachment(attachment) {
				this.post.attachment = attachment;
			},
			toggleAudioRecording() {
				this.status.recordingAudio = !this.status.recordingAudio;
			},
			handlePaste(e) {
				if(this.hasAttachment || this.status.isAddingAttachment) return;

				let text = e.clipboardData.getData('text');
				let urlRegex = /(http(s)?:\/\/.)?(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)/g
				if(urlRegex.test(text)) {
					// An url was pasted, parse it
					e.preventDefault();
					this.status.isAddingAttachment = true;
					attachment.parse(text)
						.then(attachment => {
							this.post.attachment = attachment;
						})
						.finally( _ => {
							this.status.isAddingAttachment = false;
						});
				}
			},
			uploadImage(event) {
				if(this.hasAttachment || this.status.isAddingAttachment) return;
				this.status.isAddingAttachment = true;

				let payload = new FormData($(this.$refs.imageUploadForm)[0]);

				// TODO: display upload progress
				attachment.image.upload(payload)
				.then(res => {
					if(this._isDestroyed || this._isBeingDestroyed || this.hasAttachment)
						return
					this.post.attachment = res;
				})
				.catch(err => {
					if(this._isDestroyed || this._isBeingDestroyed  || this.hasAttachment)
						return
					this.$notify({
						group: 'top',
						text: helpers.formatResponseError(err),
						type: 'error'
					});
				})
				.finally(() => {
					this.status.isAddingAttachment = false;
				});
			},
			triggerUpload() {
				this.$refs.imageUploadInput.click();
			}
		},
		created() {
			window.addEventListener('beforeunload', e => {
				if(this.post.body !== null || this.hasAttachment) {
					var confirmationMessage = 'El post que estabas editando se perderá para siempre. ¡Eso es mucho tiempo!';
					e.returnValue = confirmationMessage;
					return confirmationMessage;
				}
			});
		},
		beforeDestroy() {
			this.$root.$emit('blurToolBox', false);
		}
	}
</script>