<template>
	<div class="block" data-layout-type="form">
		<template v-if="!email_sent">
			<h2>Restablecer contraseña</h2>
			<p>Ingresa la dirección de correo electrónico de tu cuenta y te enviaremos un correo con instrucciones para restablecer tu contraseña.</p>
			<form @submit.prevent="attempt" id="pass_reset-form">
				<div class="error" v-if="errors.error">{{errors.error}}</div>
				<input v-model="email" type="email" placeholder="Correo electrónico">
				<button type="submit" :disabled="loading" class="button" data-button-size="big" data-button-font="medium" data-button-uppercase data-button-important>
					enviar
				</button>
			</form>
		</template>
		<template v-else>
			<p>Revisa la bandeja de entrada de {{email}} y sigue las instrucciones para restablecer tu contraseña</p>
		</template>
	</div>
</template>

<script>
import auth from '../api/auth'
import {baseUrl} from '../config'

export default {
	name: 'Register',
	data() {
		return {
			email: '',
			errors: '',
			loading: false,
			email_sent: false
		}
	},
	methods: {
		attempt() {
			this.loading = true;
			auth.resetPassword(this.email).then(() => {
				this.email_sent = true
			}).finally(() => {
				this.loading = false;
			})
		}
	}
}
</script>