<template>
	<div id="feed" :class="{'renderbox': loading || refreshing}" :data-renderbox-message="[loading ? 'Cargando posts...' : 'Actualizando feed...']" :data-renderbox-top="refreshing" ref="postList" v-infinite-scroll="loadMore" :infinite-scroll-disabled="infiniteScrollStill">
		<template v-if="isMasonry">
			<div v-if="firstLoad" id="masonry" ref="masonry" v-masonry transition-duration=".3s" item-selector=".little" fit-width="true">
				<template v-for="post in feed">
					<Card v-if="post.isShared" v-masonry-tile class="little" :post="post.source" :showThumbnail="showThumbnail" :key="post.id" :sharer="post.user" :isShared="post.isShared" :size="size"></Card>
					<Card v-else :post="post" v-masonry-tile class="little" :key="post.id" :showThumbnail="showThumbnail" :size="size"></Card>
				</template>
			</div>
		</template>
		<template v-else v-for="post in feed">
			<Card v-if="post.isShared" :post="post.source" :showThumbnail="showThumbnail" :key="post.id" :sharers="post.sharers" :isShared="post.isShared" :size="size"></Card>
			<Card v-else :post="post" :key="post.id" :showThumbnail="showThumbnail" :size="size"></Card>
		</template>
		<template v-if="reachedBottom && !loading && !refreshing">
			<h3 v-html="formattedNoResults" v-if="oldestId === null"></h3>
			<h3 v-html="formattedReachedBottom" v-else></h3>
		</template>
	</div>
</template>

<script>
	import feed from '../api/feed';

	import formatter from '../helpers/formatter';

	import Card from './Card/_Card.vue';

	import { mapGetters } from 'vuex';

	export default {
		props: ['name', 'filters', 'size'],
		components: {
			Card
		},

		/**
		 * Component data
		 */
		data() {
			return {
				loading: true,
				oldestId: null,
				reachedBottom: false,
				previousScrollPosition: 0,
				refreshing: false,
				firstLoad: false,
				isMasonry: true
			}
		},
		computed: {
			...mapGetters({ feed: 'feed' }),
			showThumbnail() {
				return !!this.$store.getters.settings.content_lowres_images;
			},

			formattedReachedBottom() {
				return formatter.format('Bienvenidos al fin del mundo :eggplant:');
			},

			formattedNoResults() {
				return formatter.format('¡Qué vacío está esto! [¿Quieres descubrir cosas nuevas?](/discover#recent) :smirk:');
			},
			infiniteScrollStill(){
				return this.loading || this.reachedBottom;
			}
		},
		methods: {
			noMasonry(){
				if(this.size == 'little' && window.innerWidth > 644){
					this.isMasonry = true;
					return
				}
				this.isMasonry = false;
				return
			},
			// Concatena shared post que se siguen el uno al otro
			// TODO concatenar post entre peticiones loadmore y vista actual
			concat_post(items){
				outer:
				for(var i = 0; i < items.length; i++){
					if(items[i].isShared){
						var sharers = [items[i].user];
						inner:
						for(var o = i+1; o < items.length; o++){
							if(items[o].isShared){
								if(items[o].source.id == items[i].source.id){
									//is another shared from same post, save and delete
									sharers.push(items[o].user);
									items.splice(o, 1);
									o -= 1;
								}
							}else{
								if(items[o].id == items[i].source.id){
									//is original post
									items.splice(o, 1);
									break inner;
								}
							}
						}
						items[i]['sharers'] = sharers;
					}
				}
				return items;
			},
			getPreviousScrollPosition(){
				this.previousScrollPosition = $(window).scrollTop();
			},
			reload() {
				this.refreshing = true;
				this.firstLoad = false;
				feed.get(this.name, {filters: this.filters}).then(res => {
					var _res = this.concat_post(res.items);
					if(this._isDestroyed || this._isBeingDestroyed){
						return
					}
					this.$store.dispatch('setFeedPosts', _res);
					if (res.items.length) {
						this.oldestId = res.items[res.items.length - 1].id;
					}
					this.reachedBottom = res.last_page;
					this.$store.dispatch('resetNewActivity');
				}).finally(() => {
					this.refreshing = false;
					this.firstLoad = true;
				});
			},

			/**
			 * Loads the next page of the current feed
			 */
			loadMore(){
				if(this.infiniteScrollStill){
					return
				}
				this.loading = true;
				this.getPreviousScrollPosition();
				feed.get(this.name, {before: this.oldestId, filters: this.filters}).then(res => {
					var _res = this.concat_post(res.items);
					if(this._isDestroyed || this._isBeingDestroyed){
						if(res.items.length) {
							this.$store.dispatch('setFeedPosts', _res);
							this.oldestId = res.items[res.items.length - 1].id;
						}
					}
					if(res.items.length){
						this.$store.dispatch('appendFeedPosts', _res);
						this.oldestId = res.items[res.items.length - 1].id;
					}
					this.reachedBottom = res.last_page;
				}).finally(() => {
					window.scrollTo(0, this.previousScrollPosition);
					this.loading = false;
				});
			}
		},
		watch: {
			filters() {
				this.reload();
			},
			name() {
				this.reload();
			}
		},

		/**
		 * Triggered when a component instance is created
		 */
		created(){
			feed.get(this.name, {filters: this.filters}).then(res => {
				var _res = this.concat_post(res.items);
				if(this._isDestroyed || this._isBeingDestroyed){
					return
				}
				if(res.items.length){
					this.$store.dispatch('setFeedPosts', _res);
					this.oldestId = res.items[res.items.length - 1].id;
				}
				this.reachedBottom = res.last_page;
				this.$store.dispatch('resetNewActivity');
			}).finally(() => {
				this.loading = false;
				this.firstLoad = true;
			});
			this.$root.$on('refresh_feed', this.reload);
			this.noMasonry();//check if can show masonry at page load
			window.addEventListener('resize', this.noMasonry);
		},
		beforeDestroy() {
			window.removeEventListener('resize', this.noMasonry);
		}
	}
</script>