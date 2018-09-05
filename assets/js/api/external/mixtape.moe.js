import wrap from '../wrap';
import axios from 'axios';

export default {
	get name() { return 'mixtape.moe'; },

	upload(formData) {
    formData.set('files[]', formData.get('file'));
    formData.delete('file');
		return wrap(() => axios.create().post('https://mixtape.moe/upload.php', formData));
	}
};