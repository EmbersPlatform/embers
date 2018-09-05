import axios from 'axios';
import config from './config';
import wrap from './wrap';

export default {
  /**
   * Gets posts from the specified feed
   * @param name
   * @param before
   */
  search(searchParams = '', before = null) {
    let params = {};

    if (!isNaN(before))
      params.before = before;

    return wrap(() => axios.get(`${config.prefix}/search/${searchParams}`, { params }));
  }
};