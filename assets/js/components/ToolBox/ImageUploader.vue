<template>
	<div class="image-uploader tool" :class="{'url-uploader' : (askForUrl && !askForSource), 'renderbox' : uploading}" :data-renderbox-message="[(isImporting) ? 'Importando imagen...' : 'Subiendo imagen...']">
		<ul class="picker" v-if="askForSource">
			<li class="text" @click="triggerUpload">
				<svgicon name="n_upload"></svgicon>
				<p>subir archivo</p>
			</li>
			<li class="image" @click="promptUrl">
				<svgicon name="n_worldwide"></svgicon>
				<p>importar de url</p>
			</li>
		</ul>
		<template v-if="askForUrl && !askForSource">
			<form class="importer" @submit.prevent="importImage">
				<label>No olvides presionar "enter" para importar</label>
				<input type="url" v-model="url" placeholder="URL de la imagen">
			</form>
		</template>
		<form id="imageForm" method="post" enctype="multipart/form-data" class="hidden">
			<input type="file" name="file" accept="image/*" @change="uploadImage">
		</form>
	</div>
</template>

<script>
	/**
	 * Import utilities
	 */
	import attachment from '../../api/attachment';
	import notifications from '../../notifications';
	import helpers from '../../helpers';

	/**
	 * Import additional components
	 */
	function initialData() {
		return {
			url: null,
			uploading: false,
			stage: 'ask-for-source'
		}
	}
	export default {
		name: 'ImageUploader',
		props: ['show'],
		data: initialData,
		computed: {
			askForSource() {
				return this.stage == 'ask-for-source';
			},
			askForUrl() {
				return this.stage == 'ask-for-url';
			},
			isImporting() {
				return this.stage == 'importing';
			},
		},
		methods: {
			resetData() {
				Object.assign(this.$data, initialData());
			},
			promptUrl() {
				this.stage = 'ask-for-url';
			},
			importImage() {
				this.uploading = true;
				this.stage = 'importing';

				attachment.parse(this.url)
				.then(res => {
					if(this._isDestroyed || this._isBeingDestroyed)
						return
					this.$emit('uploaded', res);
				})
				.catch(err => {
					console.log("fallo");
					if(this._isDestroyed || this._isBeingDestroyed)
						return
					notifications.error(helpers.formatResponseError(err));
					this.url = null;
					this.uploading = false;
					this.stage = 'ask-for-url'
				})
				.finally(() => {
					this.uploading = false;
				});
			},
			uploadImage(event) {
				this.uploading = true;
				this.stage = 'uploading';

				let payload = new FormData($('#imageForm')[0]);

				// TODO: display upload progress
				attachment.image.upload(payload)
				.then(res => {
					if(this._isDestroyed || this._isBeingDestroyed)
						return
					this.$emit('uploaded', res);
				})
				.catch(err => {
					if(this._isDestroyed || this._isBeingDestroyed)
						return
					notifications.error(helpers.formatResponseError(err));
					this.url = null;
					this.stage = 'ask-for-url'
				})
				.finally(() => {
					this.uploading = false;
				});
			},
			triggerUpload() {
				$('#imageForm input[name=file]').click();
			}
		},
		watch: {
			show() {
				this.resetData();
			}
		}
	}

</script>