import axios from 'axios';
import config from './config';
import wrap from './wrap';

export default {
	/**
	 * Lists notifications
	 */
	get(after = null, dismiss = false) {
		let params = { dismiss: +!!dismiss };

		if (!isNaN(after))
			params.after = after;

		return wrap(() => axios.get(`${config.prefix}/notifications`, { params }));
	},

	/**
	 * Marks every notification as read
	 */
	readAll() {
		return wrap(() => axios.patch(`${config.prefix}/notifications`));
	},

	/**
	 * Marks a single notification as read
	 * @param id
	 */
	read(id) {
		return wrap(() => axios.patch(`${config.prefix}/notifications/${id}`));
	},

	/**
	 * Deletes all unread notifications
	 */
	 delete() {
	 	return wrap(() => axios.delete(`${config.prefix}/notifications/`));
	 }
};