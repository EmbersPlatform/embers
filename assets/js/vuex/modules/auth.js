import * as types from '../types';

const state = {
	user: null
};

const mutations = {
	[types.LOGIN_SUCCESS](state, action) {
		state.user = action.user;
	},
	[types.LOGOUT](state, action) {
		state.user = null;
	},
	[types.UPDATE_USER_SUCCESS](state, action) {
		state.user = action.user;
	}
};

const actions = {
	loginSuccess({ commit }, user) {
		commit(types.LOGIN_SUCCESS, user);
	},
	updateUser({ commit }, user) {
		commit(types.UPDATE_USER_SUCCESS, { user: user });
	}
};

export default {
	state,
	mutations,
	actions
};