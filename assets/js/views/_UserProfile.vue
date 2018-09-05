<template>
	<div id="board">
		<template v-if="!loading">
			<div id="heading" class="user">
				<template>
					<hr v-if="user.cover" :style="'background-image: url('+user.cover+');'">
					<hr v-else style="background-image: url(/cover/default.jpg);">
				</template>
				<Top></Top>
				<UserCard :user="user" type="wide"></UserCard>
			</div>
			<div id="wrapper">
				<SideModules ref="side"></SideModules>
				<router-view></router-view>
			</div>
		</template>
	</div>
</template>

<script>
	import SideModules from '../components/SideModules/UserProfile.vue';
	import Top from '../components/Top.vue';
	import UserCard from '../components/UserCard.vue';
	import user from '../api/user';

	import formatter from '../helpers/formatter';

	export default {
		components: {
			SideModules,
			Top,
			UserCard
		},

		data() {
			return {
				loading: false
			}
		},
		computed: {
			user() {
				return this.$store.state.userProfile
			},
			isCover(){
				if(this.user){
					if(!this.user.cover){
						return false;
					}
					return true;
				}
				return false;
			},
			formattedBio(){
				return formatter.format(this.user.meta.bio);
			}
		},
		methods: {
			fetchUser() {
				this.$store.dispatch('setUserProfile', null);
				this.loading = true;

				user.get(this.$route.params.name).then(res => {
					if(res.data.username.toUpperCase() != this.$route.params.name.toUpperCase()){
						return
					}
					this.$store.dispatch('setUserProfile', res.data);
				}).catch(() => {
					this.$router.push('/404');
				}).finally(() => this.loading = false);

			}
		},
		watch: { '$route': 'fetchUser' },

		/**
		 * Triggered when a component instance is created
		 */
		created() {
			this.fetchUser();
		},

		/**
		 * Triggered before this component instance is destroyed
		 */
		beforeDestroy() {
			this.$store.dispatch('setUserProfile', null);

		},
	}
</script>