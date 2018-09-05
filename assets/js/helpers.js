import moment from 'moment';

/**
 * Truncates a string if needed and appends an ellipsis mark
 *
 * @param      {number}   n       Maximum number of characters
 * @param      {boolean}  bound   If true, words won't be ccut
 * @param      {<type>}   ellip   Optionally specify the ellipsis mark
 * @return     {string}   The truncated string
 */
String.prototype.trunc = String.prototype.trunc || function (n, bound, ellip) {
		const isTooLong = this.length > n;
		if (!isTooLong) {
			return this;
		}

		let str = this.substr(0, n - 1);
		if (bound) {
			str = str.substr(0, str.lastIndexOf(' '));
		}

		return str + (ellip || '...');
	};

export default {
	base64int: {
		radix: '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_-',

		encode(n) {
			if (Number.isNaN(Number(n)) || n === null || n === Number.POSITIVE_INFINITY || n < 0)
				throw 'Invalid number input';

			let remainder = Math.floor(n),
			    result = '';
			const base = this.radix.length;

			do {
				result = this.radix.charAt(remainder % base) + result;
				remainder = Math.floor(remainder / base);
			} while (remainder > 0);

			return result;
		},

		decode(str) {
			let result = 0;
			const base = this.radix.length;

			// convert string to array of characters
			str = str.toString().split('');

			for (let i = 0; i < str.length; i++) {
				result = (result * base) + this.radix.indexOf(str[i]);
			}

			return result;
		}
	},

	/**
	 * Formats controller response error messages
	 *
	 * @param      {object}  err     The error object
	 * @return     {string}  The formatted error message
	 */
	formatResponseError(err) {
		let text = '';
		if ('message' in err) {
			text = err.message;

			if (err.data && typeof err.data === 'object' && 'time_left' in err.data && err.data.time_left > 0) {
				text += ' Prueba de nuevo en ' + moment.duration(err.data.time_left, 'seconds').humanize() + '.';
			}
		} else {
			/** @todo implement this in a proper way */
			for (let k in err) {
				text += ' • ' + err[k].join('<br>') + '<br>';
			}

			text = text.substr(Object.keys(err).length === 1 ? 3 : 0, text.length - 4);
		}

		return text;
	}
};