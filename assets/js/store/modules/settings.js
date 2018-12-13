const state = {
	settings: {}
};

import * as types from '../types';

const mutations = {
	UPDATE_USER_SETTINGS: function (state, settings) {
		state.settings = settings;
	}
};

const actions = {
	updateSettings({ commit }, settings) {
		commit(types.UPDATE_USER_SETTINGS, settings);
	}
};

export default {
	state,
	mutations,
	actions
};