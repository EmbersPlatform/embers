<template>
	<!-- data status le dice a css que queremos mostrar el estado de conexion del usuario, los valores son: online, iddle, busy y offline -->
	<div class="avatar" :data-status="[status ? 'online' : '']" :class="{'shared': isShared}" :data-multi="multi_share || two_shares">
		<router-link v-if="isShared" :to="`/@${sharers[0].name}`">
			<img :src="[(sharers.length) ? sharers[0].avatar.small : '/avatar/default@64.jpg']" :data-user="sharers[0].id">
		</router-link>
		<template>
			<template v-if="!svg">
				<router-link v-if="user" :to="`/@${user}`">
					<img :src="[(avatar) ? avatar : '/avatar/default@64.jpg']">
				</router-link>
				<span v-else>
					<img :src="[(avatar) ? avatar : '/avatar/default@64.jpg']">
				</span>
				<template v-if="multi_share || two_shares">
					<span v-if="multi_share">
						<svgicon v-if="multi_share" name="s_plus"></svgicon>
					</span>
					<router-link v-else :to="`/@${sharers[sharers.length-1].name}`">
						<img :src="[(sharers.length) ? sharers[sharers.length-1].avatar.small : '/avatar/default@64.jpg']">
					</router-link>
				</template>
				<hr v-if="!isShared && status">
			</template>
			<span v-else>
				<svgicon :name="svg"></svgicon>
			</span>
		</template>
	</div>
</template>
<script>
	export default {
		props: ['status', 'avatar', 'svg', 'user', 'isShared', 'sharers'],
		computed: {
			//compartido mas de 2 veces
			multi_share(){
				if(this.sharers){
					if(this.sharers.length > 2){
						return true;
					}
					return false;
				}
				return false;
			},
			//compartido 2 veces
			two_shares(){
				if(this.sharers){
					if(this.sharers.length == 2){
						return true;
					}
					return false;
				}
				return false;
			}
		}
	}
</script>