<template>
	<div id="board">
		<div id="heading">
			<Top></Top>
		</div>
		<router-view></router-view>
	</div>
</template>
<script>
	import Top from '../components/Top.vue';
	export default {
		components: {
			Top
		}
	}
</script>