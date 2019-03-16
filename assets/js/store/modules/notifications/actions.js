export default {
  update({ commit }, notifications) {
    commit("UPDATE", notifications);
  },
  add({ commit }, notification) {
    commit("ADD", notification);
  },
  remove({ commit }, id) {
    commit("REMOVE", id);
  },
  read({ commit }, id) {
    commit("READ", id);
  },
  unread({ commit }, id) {
    commit("UNREAD", id);
  }
};
