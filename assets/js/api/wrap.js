import {
  APIError
} from './errors';
import Promise from 'bluebird';

export default function (fn) {
  return new Promise((resolve, reject) => {
    fn()
      .then(res => resolve(res.data))
      .catch(err => {
        if (typeof err.response !== 'undefined' && typeof err.response.data !== 'undefined')
          return reject(new APIError(err));

        return reject(err);
      })
      .then(() => resolve());
  });
}
