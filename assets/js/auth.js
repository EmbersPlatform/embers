import store from "./store";

export default {
  /**
   * Returns true if the user is authenticated
   * @returns {boolean}
   */
  loggedIn() {
    return store.getters.user && !!store.getters.user.id;
  }
};
