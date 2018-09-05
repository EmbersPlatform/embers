import axios from 'axios';
import config from './config';
import wrap from './wrap';

export default {
  getTags() {
    return wrap(() => axios.get(`${config.prefix}/tag/`));
  },
  getBlockedTags() {
    return wrap(() => axios.get(`${config.prefix}/tag/block`));
  },
  subscribe(tag) {
    return wrap(() => axios.post(`${config.prefix}/tag/${tag}`));
  },
  unsubscribe(tag) {
    return wrap(() => axios.delete(`${config.prefix}/tag/${tag}`));
  },
  block(tag) {
    return wrap(() => axios.post(`${config.prefix}/tag/block/${tag}`));
  },
  unblock(tag) {
    return wrap(() => axios.delete(`${config.prefix}/tag/block/${tag}`));
  }
};