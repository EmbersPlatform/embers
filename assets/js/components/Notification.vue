<template>
	<div slot="body" slot-scope="props" class="notification" :class="type" @click="props.close(); close();" rel="root">
		<avatar v-if="hasImage" :avatar="props.item.data.image" />
		<div class="notification-content">
			<a class="notification-title">
				{{props.item.title}}
			</a>
			<span class="notification-text" v-html="props.item.text"></span>
		</div>
		<button class="notification-close" @click.stop="props.close">x</button>
	</div>
</template>

<script>
import avatar from './avatar';

import Hammer from 'hammerjs';

export default {
	name: 'ToastNotification',
	props: ['props'],
	components: {avatar},
	data() {
		return {
			type: this.props.item.type,
		}
	},
	computed: {
		hasImage() {
			return (this.props.item.data && 'image' in this.props.item.data);
		}
	},
	methods: {
		close() {
			if(this.props.item.data && typeof this.props.item.data.close === 'function')
				return this.props.item.data.close();
		}
	}
}
</script>