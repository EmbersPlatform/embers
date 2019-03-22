import Vue from 'vue';
import Vuex from 'vuex';

import auth from './modules/auth';
import feed from './modules/feed';

import userMutuals from './modules/user.mutuals';
import notifications from './modules/notifications';
import settings from './modules/settings';
import chat from './modules/chat';
import tag from './modules/tag';

import * as getters from './getters';

Vue.use(Vuex);

export default new Vuex.Store({
	state: {
		appData: {},
		userProfile: {},
		originalTitle: null,
		newActivity: 0
	},

	modules: { auth, feed, userMutuals, notifications, settings, chat, tag },
	mutations: {
		SET_APP_DATA(state, data) {
			state.appData = data;
		},

		SET_USER_PROFILE(state, user) {
			state.userProfile = user;
		},
		UPDATE_TITLE(state, title = null) {
			if(title) {
				state.originalTitle = title;
			}
		},
		NEW_ACTIVITY(state) {
			state.newActivity += 1;
		},
		RESET_ACTIVITY(state) {
			state.newActivity = 0;
		}
	},

	actions: {
		setAppData({ commit }, appData) {
			commit('SET_APP_DATA', appData);
		},

		setUserProfile({ commit }, user) {
			commit('SET_USER_PROFILE', user);
		},
		updateTitle({ commit }, title = null) {
			commit('UPDATE_TITLE', title);
		},
		newActivity({ commit }) {
			commit('NEW_ACTIVITY');
		},
		resetNewActivity({ commit }) {
			commit('RESET_ACTIVITY');
		}
	},

	getters
});
