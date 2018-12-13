<template>
	<ul id="column">
		<li class="nav_">
			<h2>{{title}}</h2>
		</li>
		<li class="nav_">
			<ul>
				<li class="n_item">
					<router-link class="n_i_wrap" :to="`/@${$route.params.name}`" exact>
						<span class="n_i_w_clip">
							<svgicon name="s_activity"></svgicon>
						</span>
						<span class="n_i_w_content">actividad</span>
					</router-link>
				</li>
				<!-- <li class="n_item">
					<a href="#" class="n_i_wrap">
						<span class="n_i_w_clip">
							<svgicon name="s_account"></svgicon>
						</span>
						<span class="n_i_w_content">informacion</span>
					</a>
				</li> -->
			</ul>
		</li>
		<template v-if="isAuth">
			<li class="nav_">
				<span>amigos</span>
			</li>
			<Mutuals></Mutuals>
		</template>
	</ul>
</template>

<script>
	import user from '../../api/user';
	import Mutuals from '../../components/Mutuals';
	export default {
		components: {
			Mutuals
		},
		computed: {
			user() {
				return this.$store.state.auth.user
			},
			isAuth(){
				if(this.user){
					if(this.user.name == this.$route.params.name){
						return true;
					}
					return false;
				}
				return false;
			},
			title(){
				if(this.isAuth){
					return 'mi perfil';
				}
				return this.$route.params.name;
			}
		}
	};
</script>