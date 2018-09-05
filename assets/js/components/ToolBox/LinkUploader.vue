<template>
	<div class="url-uploader tool" :class="{'renderbox' : !askForUrl}" data-renderbox-message="Capturando metadatos...">
		<template v-if="askForUrl">
			<form class="importer" @submit.prevent="importHyperlink">
				<label>No olvides presionar "enter" para importar</label>
				<input type="url" v-model="url" placeholder="URL del enlace">
			</form>
		</template>
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
			stage: 'ask-for-url'
		}
	}
	export default {
		name: 'HyperlinkUplaoder',
		props: ['show'],
		data: initialData,
		computed: {
			askForUrl() {
				return this.stage == 'ask-for-url';
			},
			showLoader() {
				return this.stage == 'uploading';
			},
		},
		methods: {
			resetData() {
				Object.assign(this.$data, initialData());
			},
			promptUrl() {
				this.stage = 'ask-for-url';
			},
			importHyperlink() {
				this.uploading = true;
				this.stage = 'uploading';

				attachment.parse(this.url)
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
			}
		},
		watch: {
			show() {
				this.resetData();
			}
		}
	}
	
</script>