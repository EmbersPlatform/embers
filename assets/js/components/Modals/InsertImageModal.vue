<template>
	<div class="insert-image-modal">
		<form>
			<input type="text" v-model="url" placeholder="URL de la imagen" />
		</form>
		<div class="modal-buttons">
			<button class="button" data-button-size="medium" data-button-font="medium" @click="$emit('close')">Cancelar</button>
			<button class="button" data-button-size="medium" data-button-font="medium" data-button-important @click="handle">Insertar</button>
		</div>
	</div>
</template>

<script>
export default {
	name: 'InsertImageModal',
	props: ['editorId'],
	data() {
		return {
			url: null,
		}
	},
	methods: {
		handle() {
			this.$root.$emit(this.editorId+'-insert-image', this.url);
			this.$emit('close');
		}
	}
}
</script>