export default {
  TOGGLE_MEDIA_SLIDES(state, value) {
    state.show_media_slides = value;
  },
  SET_INDEX(state, index) {
    state.index = index;
  },
  SET_MEDIAS(state, medias) {
    state.medias = medias;
  }
}
