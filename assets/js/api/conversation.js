import axios from 'axios';
import config from './config';
import wrap from './wrap';

export default {
	/**
	 * Lists conversations
	 */
	get() {
		return wrap(() => axios.get(`${config.prefix}/conversation`));
	},

	/**
	 * Gets messages from the conversation with the specified user
	 * @param userId
	 */
	getMessages(userId, params = {}) {
		let query = {};

		if(typeof params.before !== 'undefined' && !isNaN(params.before)) {
			query.before = params.before;
		}

		if(typeof params.markAsRead !== 'undefined') {
			query.markAsRead = 1;
		}

		return wrap(() => axios.get(`${config.prefix}/conversation/${userId}`, { params }));
	},

	/**
	 * Sends a message/starts a conversation with the specified user
	 * @param userId
	 * @param message
	 */
	sendMessage(userId, message) {
		return wrap(() => axios.post(`${config.prefix}/conversation/${userId}`, message));
	},

	/**
	 * Marks as read a conversation with the specified user
	 * @param userId
	 * @param message
	 */
	markAsRead(userId) {
		return wrap(() => axios.get(`${config.prefix}/conversation/read/${userId}`));
	},

	/**
	 * Broadcasts a message
	 * @param message
	 */
	broadcastMessage(message) {
		return wrap(() => axios.post(`${config.prefix}/conversation/broadcast`, message));
	}
};