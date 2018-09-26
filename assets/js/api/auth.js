import axios from "axios";
import wrap from "./wrap";
import config from "./config";

export default {
  /**
   * Sign in
   * @param credentials
   */
  login(credentials) {
    return wrap(() =>
      axios.post(`${config.nonApi}/sessions`, {
        id: credentials.id,
        password: credentials.password
      })
    );
  },

  /**
   * Sign up
   * @param data
   */
  register(data) {
    return wrap(() => axios.post(`${config.nonApi}/register`, data));
  },

  /**
   * Log out
   */
  logout() {
    return wrap(() => axios.delete(`${config.nonApi}/sessions`));
  },

  /**
   * Reset password
   * @param email
   */
  resetPassword(email) {
    return wrap(() =>
      axios.post(`${config.nonApi}/password_resets`, { email })
    );
  }
};
