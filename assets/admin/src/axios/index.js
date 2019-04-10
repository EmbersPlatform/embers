import axios from 'axios';

export default {
  setup() {
    axios.interceptors.request.use(function (config) {
      config.headers.common["X-CSRF-Token"] = window.csrf_token;
      return config;
    });
  },

  get_instance() {
    return axios;
  }
}
