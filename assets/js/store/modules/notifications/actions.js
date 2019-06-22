import axios from 'axios';

export default {
  update({
    commit
  }, notifications) {
    commit("UPDATE", notifications);
  },
  add({
    commit
  }, notification) {
    commit("ADD", notification);
  },
  append({
    commit
  }, notifications) {
    commit("APPEND", notifications);
  },
  remove({
    commit
  }, id) {
    commit("REMOVE", id);
  },
  async read({
    commit
  }, id) {
    commit("READ", id);
    await axios.put(`/api/v1/notifications/${id}`);
  },
  unread({
    commit
  }, id) {
    commit("UNREAD", id);
  },
  mark_as_seen({
    commit
  }) {
    commit("MARK_AS_SEEN");
  }
};
