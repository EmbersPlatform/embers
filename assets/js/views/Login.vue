<template>
	<div class="block" data-layout-type="form">
		<form @submit.prevent="attempt" id="login-form">
			<h3>Nueva sesion</h3>
			<div class="error" v-if="errors">{{errors}}</div>
			<input v-model="id" placeholder="Nombre de usuario o e-mail" type="text" name="username" :data-error="errors" autocomplete="username email">
			<input v-model="password" placeholder="Contraseña" type="password" name="password" :data-error="errors" autocomplete="current-password">
			<button type="submit" :disabled="loading" class="button" data-button-size="big" data-button-font="medium" data-button-uppercase data-button-important>
				{{loading ? 'Verificando...' : 'Iniciar sesión'}}
			</button>
			<router-link to="/reset">Olvidé mi contraseña</router-link>
		</form>
	</div>
</template>

<script>
	import auth from '../api/auth';

	export default {
		name: 'Login',
		data() {
			return {
				id: null,
				password: null,
				errors: null,
				loading: false
			}
		},
		methods: {
			attempt() {
				this.errors = null;
				if(this.id && this.password){
					this.loading = true;
					auth.login({ id: this.id, password: this.password })
					.then(() => location.reload(true))
					.catch(err => {
						this.errors = err.res.auth;
					})
					.finally(() => this.loading = false);
				}else{
					this.errors = 'Debes rellenar ambos campos';
				}
			}
		}
	}
</script>