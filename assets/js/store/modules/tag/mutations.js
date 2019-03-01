export default {
  ADD(state, tag) {
    state.tags = [...state.tags, tag];
  },
  DELETE(state, name) {
    state.tags = state.tags.filter(tag => tag.name != name);
  },
  UPDATE(state, tags) {
    state.tags = tags;
  }
};
