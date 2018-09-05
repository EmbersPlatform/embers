import axios from 'axios';
import config from './config';
import wrap from './wrap';

import safeMoe from './external/safe.moe.js';
import mixtapeMoe from './external/mixtape.moe.js';
import piGy from './external/pi.gy.js';
import vgyMe from './external/vgy.me.js';

import randomString from '../helpers/randomString';

var providers = [
	mixtapeMoe,
	vgyMe,
];

var getProvider = function() {
	return providers[Math.round(Math.random() * (providers.length-1))];
}

export default {
	/**
	 * Image attachment
	 */
	image: {
		/**
		 * Uploads an image
		 * @param formData
		 */
		upload(formData) {
			return wrap(() => new Promise((resolve, reject) => {

				const provider = getProvider();
				provider.upload(formData).then(data => {
					axios.post(`${config.prefix}/attachment/image/sign`, {
						provider: provider.name,
						data
					}).then(resolve).catch(reject);
				}).catch(reject);
			}));
		},

		/**
		 * Imports an image
		 * @param url
		 */
		import(url, attempts = 0) {
			url = url;
			return new Promise((resolve, reject) => {
				axios.create().get(url, { responseType: 'arraybuffer' }).then(res => {
					let formData = new FormData();
					formData.append('file', new Blob([res.data], { type: res.headers['Content-Type'] }),
						url.split('/').pop().split('#')[0].split('?')[0]);
					this.upload(formData).then(resolve).catch(reject);
				}).catch(err => {
					if(attempts < 1) {
						this.import('https://cors-anywhere.herokuapp.com/' + url, attempts+1)
						.then(resolve)
						.catch(reject);
					} else {
						reject(err);
					}
				});
			});
		}
	},

	/**
	 * Video attachment
	 */
	video: {
		/**
		 * Imports a video
		 * @param url
		 */
		import(url) {
			return wrap(() => axios.post(`${config.prefix}/attachment/video/import`, { url }));
		}
	},

	/**
	 * Hyperlink attachment
	 */
	hyperlink: {
		/**
		 * Imports a hyperlink
		 * @param url
		 */
		import(url) {
			return wrap(() => axios.post(`${config.prefix}/attachment/hyperlink/import`, { url }));
		}
	},

	/**
	 * Audio attachment
	 */
	audio: {
		/**
		 * Uploads an audio
		 *
		 * @param blob
		 */
		upload(blob) {
			return wrap(() => new Promise((resolve, reject) => {
				console.log('uploading record...');
				var fileName = randomString() + '.webm';
				var file = new File([blob], fileName, {
				    type: 'video/webm'
				});
				let formData = new FormData();
				formData.append('file', file, fileName);

				const provider = mixtapeMoe;
				provider.upload(formData)
				.then(data => {
					axios.post(`${config.prefix}/attachment/audio/sign`, {
						provider: provider.name,
						data
					}).then(resolve).catch(reject);
				}).catch(reject);
			}));
		}
	},

	parse(what){
		return wrap(() => axios.post(`${config.prefix}/attachment/parse`, {url: what}));
	}
};