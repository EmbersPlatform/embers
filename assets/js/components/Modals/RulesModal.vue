<template>
	<modal
		name='rules-modal'
        :adaptive="true"
        :scrollable="true"
		:pivot-y="0.5"
        :classes="['v--modal', 'vue-dialog']"
        height="auto"
        @before-open="beforeOpened"
        @opened="opened">
        <div class="dialog-c-title">
        	Reglas de la comunidad
        </div>
		<div class="dialog-c-text" v-html="parsedRules"></div>
		<div class="modal-buttons">
			<button class="button" data-button-size="medium" data-button-font="medium" @click="$modal.hide('rules-modal')">cancelar</button>
			<button class="button" data-button-size="medium" data-button-font="medium" data-button-important @click="confirm">aceptar y registrarme</button>
		</div>
	</modal>
</template>

<script>
import axios from 'axios';
import formatter from '../../helpers/formatter';

export default {
	name: 'RulesModal',
	data() {
		return {
			rules: 'Cargando...',
			params: {},
		}
	},
	computed: {
		parsedRules() {
			return formatter.format(this.rules);
		}
	},
	methods: {
		confirm() {
			if(typeof this.params.confirm === 'function')
				this.params.confirm();
			this.$modal.hide('rules-modal');
		},
		beforeOpened (event) {
			this.params = event.params || {};
			this.$emit('before-opened', event);
		},
		opened() {
			axios.get('/public/rules-short.md')
			.then(res => {
				this.rules = res.data;
			});
		}
	},
}
</script>