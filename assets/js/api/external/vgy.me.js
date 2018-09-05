import wrap from '../wrap';
import axios from 'axios';

export default {
	get name() { return 'vgy.me'; },

	upload(formData) {
		return wrap(() => new Promise( (resolve, reject) => {
	      axios.create().post('https://vgy.me/upload', formData)
	      .then( res => {
	        var data = res.data;
	        res.data = {
	          files: [
	            {
	              name: data.filename + '.' + data.ext,
	              size: data.size,
	              url: data.image
	            }
	          ],
	          success: !data.error
	        };
	        resolve(res);
	      })
	      .catch(reject);
	    }));
	}
};