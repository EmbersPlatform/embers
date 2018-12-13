<template>
	<div id="wrapper">
		<div class="block" data-layout-type="column">
			<form>
				<input-switch class="_line" value="text" v-model="settings.privacy_show_status" :checked="settings.privacy_show_status">Mostrar a los demás usuarios si estoy en línea</input-switch>
				<input-switch class="_line" value="text" v-model="settings.privacy_show_reactions" :checked="settings.privacy_show_reactions">Los demás usuarios pueden ver a qué reaccioné</input-switch>
				<button :disabled="loading" @click.prevent="update()" class="button" data-button-size="big" data-button-font="medium" data-button-uppercase data-button-important>{{loading ? 'Guardando...' : 'Guardar cambios'}}</button>
			</form>
		</div>
	</div>
</template>

<script>
	import user from '../../api/user';
	import Switch from '../../components/inputSwitch';

	export default {
		components: {
			'input-switch': Switch
		},
		methods: {
			/**
			 * Updates privacy settings
			 */
			update() {
				this.loading = true;
				user.settings.updatePrivacy(this.settings)
					.then(res => {
						this.$store.dispatch('updateSettings', res);
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
					privacy_show_status: null,
					privacy_show_reactions: null
				}
			}
		},

		/**
		 * Triggered when an instance of this component is created
		 */
		created() {
			this.settings.privacy_show_status = !!+this.$store.getters.settings.privacy_show_status
			this.settings.privacy_show_reactions = !!+this.$store.getters.settings.privacy_show_reactions
		}
	}

</script>