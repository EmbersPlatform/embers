export default {
  add({ commit }, tag) {
    commit("ADD", tag);
  },
  delete({ commit }, name) {
    commit("DELETE", name);
  },
  update({ commit }, tags) {
    commit("UPDATE", tags);
  }
};
