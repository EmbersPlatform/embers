<template>
	<div class="multimedia">
		<template v-if="hasImage && !hasEmbedable" >
			<router-link v-if="hasPost" class="media link" :to="post.url">
				<img :src="link.meta.image">
			</router-link>
			<img v-else :src="link.meta.image">
		</template>
		<iframe v-else class="media link-embed" :src="link.meta.embed_url" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>
		<a :href="link.url" class="source" target="_blank">
			<div class="media title" target="_blank" v-if="hasTitle">{{ link.meta.title }}</div>
			<div class="media description" target="_blank" v-if="hasDescription">{{ description }}</div>
			<div class="media url" target="_blank">
				<img :src="link.meta.provider_icon" class="media provider-icon" v-if="hasProviderIcon">
				<span>{{ url }}</span>
			</div>
		</a>
	</div>
</template>

<script>
	import ellipsize from 'ellipsize';

	export default {
		name: 'LinkEmbed',
		props: ['link', 'post'],
		computed: {
			hasDescription() {
				return this.link.meta.hasOwnProperty('description') && this.link.meta.description !== null;
			},
			hasImage() {
				return this.link.meta.hasOwnProperty('image');
			},
			hasTitle() {
				return this.link.meta.hasOwnProperty('title');
			},
			hasProviderIcon() {
				return this.link.meta.hasOwnProperty('provider_icon');
			},
			hasEmbedable() {
				return this.link.meta.hasOwnProperty('embed_url');
			},
			hasPost() {
				return !!this.post;
			},
			description(){
				if(!this.hasTitle) return null;
				return ellipsize(this.link.meta.title, 80);
			},
			description(){
				if(!this.hasDescription) return null;
				return ellipsize(this.link.meta.description, 200);
			},
			url(){
				return ellipsize(this.link.url, 60);
			},
		}
	}
</script>
