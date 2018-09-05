import axios from 'axios';
import config from './config';
import wrap from './wrap';

export default {
	/**
	 * Get user
	 * @param identifier
	 */
	get(identifier) {
		return wrap(() => axios.get(`${config.prefix}/users/${identifier}`));
	},

	/**
	 * Follow user
	 * @param identifier
	 */
	follow(identifier) {
		return wrap(() => axios.post(`${config.prefix}/users/${identifier}/follow`));
	},

	/**
	 * Unfollow user
	 * @param identifier
	 */
	unfollow(identifier) {
		return wrap(() => axios.delete(`${config.prefix}/users/${identifier}/follow`));
	},

	block(identifier) {
		return wrap(() => axios.post(`${config.prefix}/users/${identifier}/block`));
	},

	unblock(identifier) {
		return wrap(() => axios.delete(`${config.prefix}/users/${identifier}/block`));
	},

	/**
	 * Kicks a user from the system
	 * @param identifier
	 */
	kick(identifier) {
		return wrap(() => axios.put(`${config.prefix}/users/${identifier}/kick`));
	},

	/**
	 * Unkicks a user from the system
	 * @param identifier
	 */
	unkick(identifier) {
		return wrap(() => axios.delete(`${config.prefix}/users/${identifier}/kick`));
	},

	/**
	 * Gets user mutuals
	 */
	getMutuals() {
		return wrap(() => axios.get(`${config.prefix}/users/${window.appData.user.id}/mutuals`));
	},
	/**
	 * Gets user online mutuals
	 */
	getOnlineMutuals() {
		return wrap(() => axios.get(`${config.prefix}/users/${window.appData.user.id}/mutuals/online`));
	},

	/**
	 * Gets users following user
	 */
	getFollowing(params = {}) {
		let query = {};
		let id = null;

		if (typeof params.before !== 'undefined' && !isNaN(params.before))
			query.before = params.before;

		if (typeof params.before !== 'undefined' && !isNaN(params.after))
			query.after = params.after;

		if (isNaN(params.id))
			id = window.appData.user.id;
		else
			id = params.id;

		return wrap(() => axios.get(`${config.prefix}/users/${id}/following`, { params }));
	},

	/**
	 * Gets users followed by user
	 */
	getFollowed(params = {}) {
		let query = {};
		let id = null;

		if (!isNaN(params.before))
			query.before = params.before;

		if (!isNaN(params.after))
			query.after = params.after;

		if (isNaN(params.id))
			id = window.appData.user.id;
		return wrap(() => axios.get(`${config.prefix}/users/${id}/followed`, { params }));
	},

	getBlocked() {
		let id = window.appData.user.id;
		return wrap(() => axios.get(`${config.prefix}/users/${id}/block`));
	},

	getPasses() {
		return wrap(() => axios.get(`${config.prefix}/users/invite/passes`));
	},

	/**
	 * User settings
	 */
	settings: {
		/**
		 * Update profile settings
		 * @param settings
		 */
		updateProfile(settings) {
			return wrap(() => axios.put(`${config.prefix}/users/settings/profile`, settings));
		},

		/**
		 * Update content settings
		 * @param settings
		 */
		updateContent(settings) {
			return wrap(() => axios.put(`${config.prefix}/users/settings/content`, settings));
		},

		/**
		 * Update privacy settings
		 * @param settings
		 */
		updatePrivacy(settings) {
			return wrap(() => axios.put(`${config.prefix}/users/settings/privacy`, settings));
		},

		/**
		 * Update profile picture
		 * @param settings
		 */
		updateAvatar(settings) {
			return wrap(() => axios.post(`${config.prefix}/users/settings/avatar`, settings));
		},

		/**
		 * Delete profile picture
		 * @param identifier
		 */
		deleteAvatar(identifier = null) {
			return wrap(() => axios.delete(`${config.prefix}/users/settings/avatar/${identifier || ''}`));
		},

		/**
		 * Update cover picture
		 * @param settings
		 */
		updateCover(settings) {
			return wrap(() => axios.post(`${config.prefix}/users/settings/cover`, settings));
		},

		/**
		 * Delete cover picture
		 * @param identifier
		 */
		deleteCover(identifier = null) {
			return wrap(() => axios.delete(`${config.prefix}/users/settings/cover/${identifier || ''}`));
		}
	},

	/** Helper methods */
	can(...permissions) {
		if (window.appData.user === null)
			return false;

		for (let permission of permissions) {
			if (window.appData.user.permissions.indexOf(permission) === -1)
				return false;
		}

		return true;
	}
};
