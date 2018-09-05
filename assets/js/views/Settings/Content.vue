<template>
	<div id="wrapper">
		<div class="block" data-layout-type="column">
			<form>
				<h2>Contenido no seguro(NSFW)</h2>
				<div class="_line">
					<input type="radio" id="settings-nsfw-show" v-model="settings.content_nsfw" value="show" :checked="settings.content_nsfw == 'show'">
					<label for="settings-nsfw-show">Mostrar el contenido NSFW</label>
				</div>
				<div class="_line">
					<input type="radio" id="settings-nsfw-ask" v-model="settings.content_nsfw" value="ask" :checked="settings.content_nsfw == 'ask'">
					<label for="settings-nsfw-ask">Preguntar antes de mostrar</label>
				</div>
				<div class="_line">
					<input type="radio" id="settings-nsfw-hide" v-model="settings.content_nsfw" value="hide" :checked="settings.content_nsfw == 'hide'">
					<label for="settings-nsfw-hide">No mostrarme contenido NSFW</label>
				</div>
				<h2>Imágenes</h2>
				<input-switch class="_line" value="text" v-model="settings.content_lowres_images" :checked="settings.content_lowres_images">Cargar imágenes de los posts en baja resolución(para conexiones muy lentas)</input-switch>
				<button :disabled="loading" @click.prevent="update()" class="button" data-button-size="big" data-button-font="medium" data-button-uppercase data-button-important>{{loading ? 'Guardando...' : 'Guardar cambios'}}</button>
			</form>
		</div>
	</div>
</template>

<script>
	import user from '../../api/user';
	import Switch from '../../components/inputSwitch.vue';

	export default {
		components: {
			'input-switch': Switch
		},
		methods: {
			/**
			 * Updates user settings
			 */
			update() {
				this.loading = true;
				user.settings.updateContent(this.settings)
					.then(settings => {
						this.$store.dispatch('updateSettings',settings);
						this.$notify({
					    	group: 'top',
					    	text: '¡Los cambios han sido aplicados!',
					    	type: "success",
					    });
					})
					.finally(() => this.loading = false);
			}
		},

		/**
		 * Component data
		 * @returns object
		 */
		data() {
			return {
				loading: false,
				settings: {
					content_nsfw: null,
					content_lowres_images: false,
				}
			};
		},

		/**
		 * Triggered when an instance of this component is created
		 */
		created() {
			this.settings.content_nsfw = this.$store.getters.settings.content_nsfw;
			this.settings.content_lowres_images = !!+this.$store.getters.settings.content_lowres_images
		}
	}
</script>