import wrap from '../wrap';
import axios from 'axios';

export default {
	get name() { return 'safe.moe'; },

	upload(formData) {
    formData.set('files[]', formData.get('file'));
    formData.delete('file');
		return wrap(() => axios.create().post('https://safe.moe/api/upload', formData));
	}
};