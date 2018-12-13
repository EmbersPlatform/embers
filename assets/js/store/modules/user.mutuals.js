import user from '../../api/user';

import * as types from '../types';

export default {
	state: { mutuals: [] },
	mutations: {
		SET_USER_MUTUALS(state, mutuals) {
			state.mutuals = mutuals;
		},

		ADD_USER_MUTUAL(state, mutual) {
			state.mutuals.unshift(mutual);
		},

		REMOVE_USER_MUTUAL(state, mutual) {
			state.mutuals = state.mutuals.filter(user => user.id !== mutual.id);
		}
	},
	actions: {
		updateMutuals({ commit }) {
			user.getMutuals().then(mutuals => {
				commit(types.SET_USER_MUTUALS, mutuals);
			});

		},

		addMutual({ commit }, mutual) {
			commit(types.ADD_USER_MUTUAL, mutual);
		},

		removeMutual({ commit }, mutual) {
			commit(types.REMOVE_USER_MUTUAL, mutual);
		}
	}
};
