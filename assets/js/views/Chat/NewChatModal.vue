<template>
	<div id="new-chat-modal" ref="modalParent">
		<div class="body">
			<form>
				<input v-model="search" type="text" class="new-chat-search" placeholder="¿Con quién quieres hablar?" @keydown.enter="startConversation">
			</form>
			<div v-if="matchingMutuals" class="nav_">
				<ul>
					<li v-for="mutual in matchingMutuals" class="n_item" :key="mutual.id">
						<span active-class="active" class="n_i_wrap" @click.prevent="userSelected(mutual.name)">
							<avatar :avatar="mutual.avatar.small"></avatar>
							<span class="n_i_w_content u_name" :data-badge="`${mutual.badges[0]}`">{{ mutual.name }}</span>
						</span>
					</li>
				</ul>
			</div>
		</div>
	</div>
</template>
<script>
	import { mapGetters } from 'vuex';
	import avatar from '../../components/avatar';

	import userAPI from '../../api/user';

	import _ from 'lodash';

	export default {
		name: 'NewChatModal',
		components: { avatar},
		data() {
			return {
				search: ''
			}
		},
		computed: {
			...mapGetters(['userMutuals']),
			...mapGetters('chat', ['conversations']),
			matchingMutuals() {
				return _.filter(this.userMutuals, o => { return o.name.indexOf(this.search) > -1 });
			}
		},
		methods: {
			fetchMutuals() {
				this.$store.dispatch('updateMutuals');
			},
			userSelected(user) {
				this.search = user;
				this.startConversation();
			},
			startConversation() {
				this.$store.dispatch('chat/updateConversation', null);

				let conversation = _.find(this.conversations, o => { return o.user.name == this.search });

				if(conversation) {
					// If the conversation already exists, load it
					this.$store.dispatch('chat/updateConversation', conversation);
					this.$store.dispatch('chat/toggleNewChatModal', false);
					this.$root.$emit('blurSidebar', false);
				} else {
					// Otherwise, create it only if the user exists
					userAPI.get(this.search)
						.then(user => {
							conversation = {
								draft: true,
								id: null,
								user: user
							};

							this.$store.dispatch('chat/updateConversation', conversation);
							this.$store.dispatch('chat/toggleNewChatModal', false);
							this.$root.$emit('blurSidebar', false);
						});
				}
			}
		},
		created() {
			this.fetchMutuals();
		},
		mounted(){
			$(this.$refs.modalParent).on('click tap', e => {
				let isChild = !!$(e.target).parents('div#new-chat-modal').length;
				if( !isChild) {
					// If click is issued outside user menu and outside menu's trigger
					this.$store.dispatch('chat/toggleNewChatModal', false);
					this.$root.$emit('blurSidebar', false);
				}
			})
		},
	}
</script>