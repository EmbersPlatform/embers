<template>
	<div id="appex" :class="{'in-app': isApp, 'blur': (blurToolBox || blurSidebar), 'fixed': fixed}" :dark-side="openSidebar" ref="main">
		<template v-if="ready">
			<template v-if="isApp">
				<Navigation v-if="user"></Navigation>
				<Sticky v-else class="in-app"></Sticky>
				<Main></Main>
				<div v-if="toHeaven || isNewActivity" class="signals">
					<button v-if="isNewActivity" @click.prevent="refreshFeed" class="new-activity" data-tip="Nueva actividad" data-tip-position="left" data-tip-text>
						{{newActivityText}}
					</button>
					<button v-if="toHeaven" @click.prevent="toTop" data-tip="Ir al cielo" data-tip-position="left" data-tip-text>
						<svgicon name="n_left-sign"></svgicon>
					</button>
				</div>
			</template>
			<template v-else>
				<Sticky></Sticky>
				<router-view></router-view>
			</template>
		</template>
		<modals-container/>
		<v-dialog/>
		<notifications group="top" position="top center" :max="3">
			<template slot="body" slot-scope="props">
				<notification :props="props" />
			</template>
		</notifications>
		<notifications group="activity" :position="($mq == 'sm') ? 'bottom center' : 'bottom right'" :max="5">
			<template slot="body" slot-scope="props">
				<notification :props="props" />
			</template>
		</notifications>
		<rules-modal />
	</div>
</template>

<script>
	import Navigation from './layout/Navigation.vue'
	import Main from './layout/Main.vue'
	import Sticky from './layout/Sticky.vue'
	import { mapGetters } from 'vuex'
	import userResource from './api/user'
	import _ from 'lodash'
	import Hammer from 'hammerjs'

	import RulesModal from './components/Modals/RulesModal';

	import Notification from './components/Notification';

	export default {
		components: {
			Navigation,
			Main,
			Sticky,
			Notification,
			RulesModal
		},
		data() {
			return {
				ready: true,
				searchParams: '',
				newMessageTitle: false,
				newMessageTitleInterval: null,
				toHeaven: false,
				blurToolBox: false,
				blurSidebar: false,
				openSidebar: false,
				fixed: false,
			}
		},
		methods: {
			toTop() {
				$('html, body').animate({scrollTop:0}, 500, 'swing');
			},
			refreshFeed() {
				this.toTop();
				this.$root.$emit('refresh_feed');
				this.newActivity = 0;
			},
		},
		computed: {
			...mapGetters({
				user: 'user',
				notifications_count: 'notifications_count',
				title: 'title',
				newActivity: 'newActivity',
			}),
			...mapGetters('chat', ['new_message']),
			isApp: function(){
				switch(this.$route.name){
					case 'rules':
					case 'faq':
					case 'acknowledgment':
					case 'login':
					case 'register':
					case 'reset':
					case '404':
						return false
						break;
					default:
						return true
						break;
				}
			},
			newActivityText() {
				let posts = this.newActivity;
				if(posts > 9){
					return '+9';
				}
				return posts;
			},
			isNewActivity(){
				switch(this.$route.matched[0].name){
					case 'home':
						return this.newActivity > 0;
						break;
					default:
						return false;
						break;
				}
			},
		},
		created() {
			// Handle search dynamic title
			document.title = this.title;
			this.searchParams = this.$route.params.searchParams;
			this.$root.$on('search-update', params => {
				this.searchParams = params;
			});

			window.addEventListener('scroll', _.throttle(() => {
				this.toHeaven = $(window).scrollTop() >= 300;
			}), 1000);
			this.$root.$on('blurToolBox', (data) => {
				this.blurToolBox = data;
			});
			this.$root.$on('blurSidebar', (data) => {
				this.blurSidebar = data;
			});
			this.$root.$on('toggleSidebar', () => {
				this.openSidebar = !this.openSidebar;
			});
			this.$root.$on('openSidebar', () => {
				this.openSidebar = true;
			});
			this.$root.$on('closeSidebar', () => {
				this.openSidebar = false;
			});
			this.$root.$on('fixed', () => {
				this.fixed = !this.fixed;
			});

			window.addEventListener('storage', e => {
				const key = e.key;
				if(key === 'newMessages') {
					this.$store.dispatch('chat/newMessage', e.newValue, false);
				}
				if(key === 'unreadMessagesCount') {
					this.$store.dispatch('chat/updateUnreadMessagesCount', e.newValue, false);
				}
			});
		},
		mounted() {
			/**
			 * Hammer.js gestures
			 *
			 * Note that #apex is the top most parent of the application markup, so
			 * child components need to stop their propagation in order to work properly
			 */
			delete Hammer.defaults.cssProps.userSelect; // http://hammerjs.github.io/tips/ “I can’t select my text anymore!”
			let hmMain = new Hammer(this.$refs.main);
			hmMain.on('swiperight', event => {
				this.$root.$emit('openSidebar');
			});
			hmMain.on('swipeleft', event => {
				this.$root.$emit('closeSidebar');
			});
		},
		watch: {
			notifications_count: function() {
				this.$store.dispatch('updateTitle');
			},
			title(val) {
				document.title = val;
			},
			new_message() {
				if(this.new_message) {
					this.newMessageTitleInterval = setInterval(() => {
						const title = (this.title === document.title) ? 'Tienes mensajes sin leer' : this.title;
						document.title = title;
					}, 1500);
				} else {
					clearInterval(this.newMessageTitleInterval);
					document.title = this.title;
				}
			}
		},
		sockets: {
			new_chat_message(data) {
				this.$store.dispatch('chat/newMessage', true);
 			},
 			new_feed_activity() {
				this.$store.dispatch('newActivity');
			}
		},
		beforeDestroy() {
			window.removeEventListener('scroll');
		}
	}
</script>
