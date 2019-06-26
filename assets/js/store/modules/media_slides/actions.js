export default {
  toggle_media_slides({
    commit
  }, value) {
    commit("TOGGLE_MEDIA_SLIDES", value);
  },
  set_index({
    commit
  }, index) {
    commit("SET_INDEX", index);
  },
  set_medias({
    commit
  }, medias) {
    commit("SET_MEDIAS", medias);
  },
  open({
    dispatch
  }, {
    medias,
    index
  }) {
    dispatch("toggle_media_slides", true);
    dispatch("set_medias", medias);
    dispatch("set_index", index);
  },
  close({
    dispatch
  }) {
    dispatch("toggle_media_slides", false);
    dispatch("set_medias", []);
    dispatch("set_index", null);
  }
}
