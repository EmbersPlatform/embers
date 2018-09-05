<template>
	<div id="board">
		<div id="heading">
			<Top></Top>
		</div>
		<div id="wrapper">
			<SideModule></SideModule>
			<div id="content" data-layout-type="single-column">
				<ToolBox v-if="auth.loggedIn()"></ToolBox>
				<div id="filtering" :class="{'open': open}">
					<div class="controls">
						<button class="filter-button" @click.prevent="toggleFilterControls">
							<i class="fas fa-filter"></i>&nbsp;{{open ? 'Ocultar filtros' : 'Filtrar'}}
						</button>
						<button class="filter-button" @click.prevent="refreshFeed">
							<i class="fas fa-sync-alt"></i></i>&nbsp;Actualizar
						</button>
					</div>
					<div class="triggers" ref="filterControls">
						<div class="row">
							<h5>Tipo</h5>
							<CheckBox class="_line" value="text" v-model="feedFilters">Texto</CheckBox>
							<CheckBox class="_line" value="image" v-model="feedFilters">Imagen</CheckBox>
							<CheckBox class="_line" value="video" v-model="feedFilters">Video</CheckBox>
							<CheckBox class="_line" value="audio" v-model="feedFilters">Audio</CheckBox>
							<CheckBox class="_line" value="link" v-model="feedFilters">Link</CheckBox>
						</div>
						<div class="row">
							<h5>Contenido</h5>
							<CheckBox class="_line" value="nsfw" v-model="feedFilters">NSFW</CheckBox>
							<CheckBox class="_line" value="sfw" v-model="feedFilters">Sólo SFW</CheckBox>
						</div>
					</div>
				</div>
				<Feed :filters="feedFilters"></Feed>
			</div>
		</div>
	</div>
</template>

<script>
	import _ from 'lodash';

	import auth from '../auth';
	import formatter from '../helpers/formatter';

	import ToolBox from '../components/ToolBox/_ToolBox.vue';
	import Feed from '../components/Feed.vue';
	import CheckBox from '../components/inputCheckbox.vue';
	import SideModule from '../components/SideModules/Default.vue';
	import Top from '../components/Top.vue';

	export default {
		name: 'Home',
		components: {
			ToolBox,
			Feed,
			CheckBox,
			SideModule,
			Top
		},
		/**
		 * Component data
		 * @returns object
		 */
		data() {
			return {
				auth,
				feedFilters: [],
				open: false
			};
		},

		methods: {
			toggleFilterControls() {
				this.open = !this.open;
			},

			refreshFeed() {
				this.$root.$emit('refresh_feed');
			}
		},

		/**
		 * Triggered before this component instance is destroyed
		 */
		destroyed() {
			this.$store.dispatch('cleanFeedPosts');
		}
	}
</script>