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
	import AuthorizedClients from '../../components/passport/AuthorizedClients'
	import Clients from '../../components/passport/Clients'
	import PersonalAccessTokens from '../../components/passport/PersonalAccessTokens'

	export default {
		components: {
			'clients': Clients,
			'authorized-clients': AuthorizedClients,
			'personal-access-tokens': PersonalAccessTokens
		},
	}
</script>