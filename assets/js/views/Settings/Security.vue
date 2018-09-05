<template>
	<div id="wrapper">
		<div class="block" data-layout-type="column">
			<form>
				<label>NOTA: Esta característica aún no ha sido implementada.</label>
				<button class="button" data-button-size="big" data-button-font="medium" data-button-uppercase data-button-important>Cambiar contraseña</button>
				<button :disabled="loading" @click.prevent="update()" class="button" data-button-size="big" data-button-font="medium" data-button-uppercase data-button-important>Guardar cambios</button>
			</form>
		</div>
	</div>
</template>

<script>
	import user from '../../api/user';

	export default {
		components: {},

		/**
		 * Component data
		 * @returns object
		 */
		data() {
			return {
				loading: false,
			}
		}
	}

</script>