<template>
	<div id="wrapper">
		<div class="block" data-layout-type="column">
			<clients></clients>
			<authorized-clients></authorized-clients>
			<personal-access-tokens></personal-access-tokens>
		</div>
	</div>
</template>

<script>
	import AuthorizedClients from '../../components/passport/AuthorizedClients.vue'
	import Clients from '../../components/passport/Clients.vue'
	import PersonalAccessTokens from '../../components/passport/PersonalAccessTokens.vue'

	export default {
		components: {
			'clients': Clients,
			'authorized-clients': AuthorizedClients,
			'personal-access-tokens': PersonalAccessTokens
		},
	}
</script>