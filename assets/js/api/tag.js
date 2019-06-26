import axios from 'axios';
import config from './config';
import wrap from './wrap';

export default {
  getTags() {
    return wrap(() => axios.get(`${config.prefix}/subscriptions/tags/list`));
  },
  getBlockedTags() {
    return wrap(() => axios.get(`${config.prefix}/subscriptions/tags/blocked`));
  },
  subscribe(tag) {
    return wrap(() => axios.post(`${config.prefix}/subscriptions/tags/${tag}`));
  },
  unsubscribe(tag) {
    return wrap(() => axios.delete(`${config.prefix}/subscriptions/tags/${tag}`));
  },
  block(tag) {
    return wrap(() => axios.post(`${config.prefix}/tag/block/${tag}`));
  },
  unblock(tag) {
    return wrap(() => axios.delete(`${config.prefix}/tag/block/${tag}`));
  }
};
