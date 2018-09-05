<template>
	<ul :class="{renderbox : loading}">
		<template v-if="!loading">
			<li v-for="notification in notifications" :class="{ unread: !notification.read }">
				<router-link :to="notification.link">
					<avatar :avatar="notification.body.avatar" :alt="notification.body.subject"></avatar>
					<div class="tip">
						<p>
							<strong>{{notification.body.subject}}</strong> {{notification.body.predicate}}
						</p>
						<span>{{$moment.utc(notification.created_at).local().from()}}</span>
					</div>
				</router-link>
			</li>
			<li class="notifications-empty" v-if="notifications.length === 0">
				<div class="tip">
					<p>Y en el inicio... había silencio.</p>
				</div>
			</li>
		</template>
	</ul>
</template>

<script>
	import notification from '../api/notification';

	import { mapGetters } from 'vuex';
	import avatar from './avatar';

	export default {
		components: {
			avatar
		},
		computed: {
			...mapGetters({ notifications: 'notifications' }),
		},
		methods: {
			loadNotifications() {
				this.loading = true;
				notification.get(this.notifications.length ? this.notifications[this.notifications.length - 1].id : null, true).then(res => {
					// console.log('updating count')
					this.$store.commit('UPDATE_NOTIFICATIONS_COUNT', 0);
					this.$store.commit('UPDATE_NOTIFICATIONS', res.items);
				}).finally(() => this.loading = false);
			}
		},

		/**
		 * Component data
		 * @returns object
		 */
		data() {
			return {
				loading: false
			}
		},

		/**
		 * Triggered when an instance of this component is created
		 */
		created() {
			this.loadNotifications();
			this.$root.$on('update-notifications-tab', () => this.loadNotifications());
		}
	}
</script>