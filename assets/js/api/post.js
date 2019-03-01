import axios from "axios";
import config from "./config";
import wrap from "./wrap";

export default {
  /**
   * Create post
   * @param post
   */
  create(post) {
    return wrap(() => axios.post(`${config.prefix}/posts`, post));
  },

  /**
   * Get a post
   * @param      id
   */
  get(id) {
    return wrap(() => axios.get(`${config.prefix}/posts/${id}`));
  },

  /**
   * Delete post
   * @param id
   */
  deletePost(id) {
    return wrap(() => axios.delete(`${config.prefix}/posts/${id}`));
  },

  /**
   * Add reaction
   * @param id
   * @param type
   */
  addReaction(id, type) {
    return wrap(() =>
      axios.post(`${config.prefix}/posts/${id}/reaction/${type}`)
    );
  },

  /**
   * Delete reaction
   * @param id
   * @param type
   */
  deleteReaction(id, type) {
    return wrap(() =>
      axios.delete(`${config.prefix}/posts/${id}/reaction/${type}`)
    );
  },

  /**
   * Get detailed reactions
   * @param id
   */
  getReactionsDetails(id) {
    return wrap(() => axios.get(`${config.prefix}/posts/${id}/reaction`));
  },

  /**
   * Adds a post to favorites
   * @param id
   */
  favorite(id, type) {
    return wrap(() => axios.post(`${config.prefix}/feed/favorites/${id}`));
  },

  /**
   * Removes a post from favorites
   * @param id
   */
  unfavorite(id, type) {
    return wrap(() => axios.delete(`${config.prefix}/feed/favorites/${id}`));
  },

  nsfw(id, value) {
    return wrap(() =>
      axios.patch(`${config.prefix}/posts/${id}/nsfw`, { value: value })
    );
  },

  share(id) {
    return wrap(() => axios.post(`${config.prefix}/posts/${id}/share`));
  }
};
