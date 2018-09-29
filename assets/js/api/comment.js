import axios from "axios";
import config from "./config";
import wrap from "./wrap";

export default {
  /**
   * Get post comments
   * @param postId
   * @param after
   */
  get(postId, before = null, after = null) {
    let params = {};

    if (!isNaN(before)) params.before = before;

    if (!isNaN(after)) params.after = after;

    return wrap(() =>
      axios.get(`${config.prefix}/posts/${postId}/replies`, { params })
    );
  },

  /**
   * Comment on a post
   * @param postId
   * @param comment
   */
  create(postId, comment) {
    return wrap(() => axios.post(`${config.prefix}/posts/${postId}`, comment));
  },

  /**
   * Delete a comment
   * @param postId
   * @param commentId
   */
  deleteComment(postId, commentId) {
    return wrap(() => axios.delete(`${config.prefix}/posts/${commentId}`));
  },

  /**
   * Add reaction
   * @param id
   * @param type
   */
  addReaction(id, type) {
    return wrap(() =>
      axios.post(`${config.prefix}/comment/${id}/reaction/${type}`)
    );
  },

  /**
   * Delete reaction
   * @param id
   * @param type
   */
  deleteReaction(id, type) {
    return wrap(() =>
      axios.delete(`${config.prefix}/comment/${id}/reaction/${type}`)
    );
  },

  /**
   * Get detailed reactions
   * @param id
   */
  getReactionsDetails(id) {
    return wrap(() => axios.get(`${config.prefix}/comment/${id}/reaction`));
  }
};
