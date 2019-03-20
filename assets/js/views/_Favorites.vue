<template>
	<div id="board">
		<div id="heading">
			<Top></Top>
		</div>
		<div id="wrapper" data-layout-type="column">
			<div class="block" data-layout-type="column">
				<h2>Favoritos</h2>
			</div>
			<div id="content" data-layout-type="masonry">
				<Feed name="favorites" :filters="filters" size="little"></Feed>
			</div>
		</div>
	</div>
</template>
<script>
	import auth from '../auth';
	import Feed from '../components/Feed';
	import Top from '../components/Top';

	export default {
		name: 'Discover',
		components: {
			Feed,
			Top
		},
		/**
		 * Component data
		 * @returns object
		 */
		data() {
			return {
				auth
			};
		},
		methods:{},

		/**
		 * Triggered before this component instance is destroyed
		 */
		destroyed() {
			this.$store.dispatch('cleanFeedPosts');
		}
	}
</script>