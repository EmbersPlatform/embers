<template>
	<li class="nav_ mutuals">
		<ul :class="{'renderbox' : loading}">
			<li v-for="user in orderedMutuals" class="n_item" :key="user.id" :class="{offline: !user.online}">
				<router-link :to="`/chat/${user.id}`" active-class="active" class="n_i_wrap">
					<avatar :avatar="user.avatar.small" :status="user.online"></avatar>
					<span class="n_i_w_content u_name" :data-badge="`${user.badges[0]}`">{{ user.name }}</span>
				</router-link>
			</li>
			<!-- <li class="n_item">
				<button id="new_friend" class="n_i_wrap">
					<avatar svg="s_plus"></avatar>
					<span class="n_i_w_content">añadir amigo</span>
				</button>
			</li> -->
			<li key="no-results" class="no-results" v-if="userMutuals.length === 0 && !loading" v-html="formattedNoMutuals"></li>
		</ul>
	</li>
</template>

<script>
	import { mapGetters } from 'vuex';

	import formatter from '../helpers/formatter';
	import avatar from './avatar';

	export default {
		name: 'Mutuals',
		components: { avatar},
		props: ['online'],

		/**
		 * Computed data
		 */
		computed: {
			...mapGetters(['userMutuals']),

			/**
			 * Text to display when the user's no mutuals
			 */
			formattedNoMutuals() {
				return formatter.format('¡Hora de hacer amigos! :metal:')
			},
			orderedMutuals() {
				return _.orderBy(this.userMutuals, ['online'], ['desc']);
			}
		},

		watch: {
			userMutuals() {
				this.loading = false;
			}
		},

		/**
		 * Component data
		 * @returns
		 */
		data() {
			return {
				loading: true
			}
		},

		/**
		 * Triggered when this component is created
		 */
		created() {
			this.$store.dispatch('updateMutuals');
		}
	}
</script>
