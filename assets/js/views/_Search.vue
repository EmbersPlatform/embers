<template>
	<div id="board">
		<div id="heading">
			<Top></Top>
		</div>
		<div id="wrapper">
			<div id="content" data-layout-type="masonry">
				<div id="feed" :class="{renderbox : (loading || loadingMore), 'showing' : !loading && (hasPost || hasUsers)}" :data-renderbox-message="[loadingMore ? 'Cargando más resultados...' : 'Buscando...']" v-infinite-scroll="loadMore" :infinite-scroll-disabled="infiniteScrollStill">
					<template v-if="!loading">
						<template v-if="hasPost || hasUsers">
							<template v-if="results.users.length > 0">
								<h3>
									<p>Usuarios:</p>
								</h3>
								<UserCard v-if="user" v-for="user in results.users" :key="user.id" :user="user" type="compact"></UserCard>
							</template>
							<template v-if="results.posts.items.length > 0" >
								<h3>
									<p>Posts:</p>
								</h3>
								<div v-if="isMasonry" id="masonry" v-masonry transition-duration=".3s" item-selector=".little" fit-width="true">
									<Card v-for="post in results.posts.items" :key="post.id" v-masonry-tile class="little" :post="post" size="little"></Card>
								</div>
								<Card v-else v-for="post in results.posts.items" :key="post.id" :post="post" size="medium"></Card>
							</template>
						</template>
						<h3 v-if="(!hasPost && !hasUsers) || reachedBottom" :class="{'bottom': reachedBottom && (hasPost || hasUsers)}">
							<p v-html="formatted"></p>
						</h3>
					</template>
				</div>
			</div>
		</div>
	</div>
</template>
<script>
	import searchApi from '../api/search';
	import Card from '../components/Card/_Card.vue';
	import UserCard from '../components/UserCard.vue';
	import Top from '../components/Top.vue';
	import formatter from '../helpers/formatter';

	import _ from 'lodash';

	export default {
		components: {
			Card,
			UserCard,
			Top
		},
		data() {
			return {
				loading: true,
				loadingMore: false,
				searchParams: null,
				results: {},
				oldestId: null,
				reachedBottom: false,
				previousScrollPosition: 0,
				isMasonry: true
			}
		},
		computed: {
			infiniteScrollStill(){
				return this.loading || this.reachedBottom;
			},
			hasPost(){
				if(jQuery.isEmptyObject(this.results.posts)){
					return false;
				}
				if(jQuery.isEmptyObject(this.results.posts.items)){
					return false;
				}
				return true;
			},
			hasUsers(){
				if(jQuery.isEmptyObject(this.results.users)){
					return false;
				}
				return true;
			},
			formatted() {
				return (this.reachedBottom && (this.hasPost || this.hasUsers)) ? formatter.format('No hay mas resultados :eggplant:') : 'No pudimos encontrar lo que buscabas :c';
			}
		},
		methods: {
			noMasonry(){
				if(window.innerWidth > 644){
					this.isMasonry = true;
					return
				}
				this.isMasonry = false;
				return
			},
			getPreviousScrollPosition(){
				this.previousScrollPosition = $(window).scrollTop();
			},
			search() {
				if(this._isDestroyed || this._isBeingDestroyed){
					return
				}
				this.results = {};
				this.loading = true;
				if (!this.searchParams) {
					return this.loading = false;
				}
				searchApi.search(this.searchParams).then(res => {
					this.results = res;
					if (res.posts.items.length) {
						this.oldestId = res.posts.items[res.posts.items.length - 1].id;
					}
					this.reachedBottom = res.posts.last_page;
				}).finally(() => this.loading = false);
			},
			loadMore: _.debounce(function() { // Debounce the function so it is not called multiple times
				if (this.infiniteScrollStill){
					return;
				}
				this.loadingMore = true;
				this.getPreviousScrollPosition();
				searchApi.search(this.searchParams, this.oldestId).then(res => {
					if(this._isDestroyed || this._isBeingDestroyed){
						return
					}
					if (res.posts.items.length) {
						// If there are new results, create an array of posts with non duplicate ids
						this.results.posts.items = _.unionBy(this.results.posts.items, res.posts.items, 'id');
						// Set the oldest post id for the next search page
						this.oldestId = res.posts.items[res.posts.items.length - 1].id;
					}
					this.reachedBottom = res.posts.last_page;
				}).finally(() => {
					window.scrollTo(0, this.previousScrollPosition);
					this.loadingMore = false;
				});
			}, 1000),
		},
		watch: {
			'$route': function (to, from) {
				this.searchParams = to.params.searchParams;
				this.$root.$emit('search-update', to.params.searchParams);
				this.search();
			}
		},
		created() {
			this.searchParams = this.$route.params.searchParams;
			this.search();

			this.$root.$on('search', params => {
				this.searchParams = params;
				this.search();
			})
			this.noMasonry();//check if can show masonry at page load
			window.addEventListener('resize', this.noMasonry);
		},
		beforeDestroy() {
			window.removeEventListener('resize', this.noMasonry);
		}
	}
</script>