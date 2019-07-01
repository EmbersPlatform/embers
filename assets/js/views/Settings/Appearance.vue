<template>
	<div id="wrapper" data-layout-type="column">
		<div class="block" data-layout-type="column">
			<h2>Portada</h2>
		</div>
		<div class="block" data-layout-type="wide">
			<div class="cover">
				<hr v-if="user.cover" :style="'background-image: url('+user.cover+');'">
				<hr v-else style="background-image: url(/cover/default.jpg);">
			</div>
		</div>
		<div class="block" data-layout-type="column">
			<form id="cover-upload" method="post" enctype="multipart/form-data">
				<label>La portada se redimensionará a 960x320 píxeles.</label>
				<button :disabled="loading" @click.prevent="selectImage" class="button" data-button-size="big" data-button-font="medium" data-button-uppercase data-button-important>{{loading ? 'Subiendo...' : 'Cambiar portada'}}</button>
				<input class="hidden" type="file" name="cover" @change="uploadCover">
			</form>
		</div>
	</div>
</template>

<script>
	import user from '../../api/user';

	export default {
		components: {},
		methods: {
			/**
			 * Uploads a new user cover image
			 */
			uploadCover() {
				this.loading = true;
				user.settings.updateCover(new FormData($('#cover-upload')[0]))
					.then(url => this.$store.getters.user.cover = url)
					.finally(() => this.loading = false);
			},

			/**
			 * Simulates a click over the file input
			 */
			selectImage() {
				$('#cover-upload input[name=cover]').click();
			}
		},

		/**
		 * Component data
		 * @returns object
		 */
		data() {
			return {
				loading: false
			};
		},
		computed: {
			user() { return this.$store.getters.user; },
		}
	}
</script>
