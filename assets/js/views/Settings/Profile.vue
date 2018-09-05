<template>
	<div id="wrapper">
		<div id="secondary">
			<avatar data-size="wide" :avatar="$store.getters.user.avatar.medium" :data-uploading-percent="[(uploadingAvatar) ? avatarProgress+'%' : '']"></avatar>
			<button :disabled="uploadingAvatar" @click.prevent="selectImage" class="button" data-button-size="medium" data-button-font="medium">{{uploadingAvatar ? 'Subiendo...' : 'Subir imagen'}}</button>
			<form class="hidden" id="avatar-upload" method="post" enctype="multipart/form-data">
				<input type="file" name="avatar" @change="uploadAvatar">
			</form>
		</div>
		<div class="block" data-layout-type="column">
			<form>
				<label>Nombre de usuario</label>
				<input type="text" :value="$store.getters.user.name" autocomplete="username" readonly>
				<label>Correo electrónico</label>
				<input id="email" type="email" v-model="email" autocomplete="email" required>
				<label>Mensaje de perfil</label>
				<textarea name="bio" id="bio" v-model="bio" class="form-control" placeholder="¡Di algo sobre ti!" data-autoresize></textarea>
				<button :disabled="loading" @click.prevent="update()" class="button" data-button-size="big" data-button-font="medium" data-button-uppercase data-button-important>{{loading ? 'Guardando...' : 'Guardar cambios'}}</button>
			</form>
		</div>
	</div>
</template>

<script>
	import user from '../../api/user';

	import avatar from '../../components/avatar';

	export default {
		components: { avatar },
		methods: {
			/**
			 * Update user information
			 */
			update() {
				this.loading = true;
				user.settings.updateProfile({ email: this.email, bio: this.bio })
				    .then(res => {
					    this.$store.dispatch('updateSettings', res);
					    this.$notify({
					    	group: 'top',
					    	text: '¡Los cambios en tu perfil han sido aplicados!',
					    	type: "success",
					    });
				    })
				    .finally(() => this.loading = false);
			},

			/**
			 * Avatar upload handler
			 */
			uploadAvatar() {
				this.uploadingAvatar = true;
				user.settings.updateAvatar(new FormData($('#avatar-upload')[0]), {
							onUploadProgress: progress => this.onAvatarProgress(progress)
						})
				    .then(avatar => this.$store.getters.user.avatar = avatar)
				    .finally(() => {
				    	this.uploadingAvatar = false;
				    	this.avatarProgress = 0;
				    });
			},

			/**
			 * Simulates click over an invisible "Browse..." button
			 */
			selectImage() {
				$('#avatar-upload input[name=avatar]').click();
			},

			onAvatarProgress(progress) {
				console.log(progress);
				this.avatarProgress = progress;
			}
		},

		/**
		 * Component data
		 * @returns object
		 */
		data() {
			return {
				email: '',
				bio: '',
				loading: false,
				uploadingAvatar: false,
				avatarProgress: 0,
			}
		},

		/**
		 * Triggered when a component instance is created
		 */
		created() {
			this.email = this.$store.getters.user.email;
			this.bio = this.$store.getters.user.meta.bio;
		}
	}
</script>