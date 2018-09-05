<template>
	<div id="main" :data-layout-type="isChat" :data-vh-issue="isChromeMobile && isChat">
		<aside v-if="user" id="sidebar" ref="trg_sidebar" @click="sidebarClick">
			<router-view name="sidebar" v-if="isSidebar"></router-view>
		</aside>
		<router-view></router-view>
	</div>
</template>
<script>
	import { mapGetters } from 'vuex'

	export default {
		data(){
			return {
				isSidebar: false,
				isDetachSidebar: true,
				isChromeMobile: false // due to a vh issue en mobile version of chrome browser (ios/android)
			}
		},
		methods: {
			showSidebar(){
				if(window.innerWidth < 1165){
					if(window.innerWidth < 645){
						return true;
					}
					return false;
				}
				return true; //show by default
			},
			onResize() {
				if(this.isDetachSidebar && this.showSidebar()){
					// abrir sidebar pero permitir preguntar
					this.isSidebar = true;
					this.isDetachSidebar = false;
					this.$root.$emit('blurSidebar', false);
				}else{
					if(this.showSidebar()){
						// abrir sidebar pero permitir preguntar
						this.isSidebar = true;
					}else{
						// sidebar destach avaliable
						if(this.isSidebar){
							// if sidebar open close on resize call
							// cerrar sidebar y no preguntar mas
							this.isSidebar = false;
							this.isDetachSidebar = true;
							this.$root.$emit('blurSidebar', false);
						}
					}
				}
			},
			onLoad(){
				if(this.showSidebar()){
					//abrir sidebar
					this.isDetachSidebar = false;
					this.isSidebar = true;
				}
				//mantener cerrado si no
			},
			sidebarClick(e){
				if(e.target.id == 'sidebar') return;
				if (this.$mq == 'sm') this.$root.$emit('closeSidebar');
			}
		},
		computed: {
			...mapGetters({
				user: 'user'
			}),
			noSidebar (){
				switch(this.$route.matched[0].name){
					case 'search':
						return true;
						break;
					default:
						return false;
						break;
				}
			},
			isChat(){
				switch(this.$route.matched[0].name){
					case 'chat':
						return 'chat';
						break;
					default:
						return false;
						break;
				}
			}
		},
		created() {
			this.onLoad();
			window.addEventListener('resize', this.onResize);
			var uA = navigator.userAgent;
			if(uA.indexOf('Mobi') !== -1 && uA.indexOf('Chrome') !== -1){
				this.isChromeMobile = true;
			}
		},
		mounted(){
			$(this.$refs.trg_sidebar).on({
				'click tap': () => {
					if(!this.noSidebar && !this.showSidebar()){
						this.$root.$emit('blurSidebar', true);
						this.isSidebar = true;
					}
				},
			})
			$(window).on('click tap', e => {
				if(!this.showSidebar() && this.isSidebar){
					let isChild = !!$(e.target).parents('aside#sidebar').length;
					let isTrigger = $(this.$refs.trg_sidebar).is(e.target.closest('aside'));
					if( !isChild && !isTrigger ) {
						// If click is issued outside user menu and outside menu's trigger
						this.$root.$emit('blurSidebar', false);
						this.isSidebar = false;
					}
				}
			})
		},
		beforeDestroy() {
			window.removeEventListener('resize', this.onResize);
		}
	}
</script>