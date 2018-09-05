const state = {
	notifications: {},
	notifications_count: 0,
	originalTitle: null
};

import * as types from '../types';
import store from '../store';

const mutations = {
	INIT_NOTIFICATIONS: function (state, count) {
		state.notifications_count = count;
	},
	UPDATE_NOTIFICATIONS: function (state, notifications) {
		state.notifications = notifications;
	},
	UPDATE_NOTIFICATIONS_COUNT: function (state, count) {
		state.notifications_count = count;
	},
};

const actions = {
	initNotifications({ commit }, count) {
		commit(types.INIT_NOTIFICATIONS, count);
	},
	updateNotifications({ commit }, notifications) {
		commit(types.UPDATE_NOTIFICATIONS, notifications);
		commit(types.UPDATE_NOTIFICATIONS_COUNT, notifications.length);
	},
	newNotification({ commit, state }) {
		commit(types.UPDATE_NOTIFICATIONS_COUNT, state.notifications_count+1);
	},
	markAsRead({ commit }) {
		commit(types.UPDATE_NOTIFICATIONS_COUNT, 0);
	},
};

export default {
	state,
	mutations,
	actions
};