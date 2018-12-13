import * as types from "../types";
import _ from "lodash";

export default {
  state: {
    posts: [],
    new_posts: []
  },

  mutations: {
    CLEAN_FEED_POSTS(state) {
      state.posts = [];
    },

    SET_FEED_POSTS(state, posts) {
      state.posts = posts;
    },

    ADD_FEED_POST(state, post) {
      state.posts.unshift(post);
    },

    APPEND_FEED_POSTS(state, posts) {
      posts.forEach(post => state.posts.push(post));
    },

    REMOVE_FEED_POST(state, post) {
      state.posts.splice(state.posts.indexOf(post), 1);
    },

    SET_FEED_POST(state, data) {
      state.posts.splice(state.posts.indexOf(data.post), 1, data.newPost);
    },
    ADD_NEW_POST(state, post) {
      state.new_posts = [post, ...state.new_posts];
    },
    PREPEND_NEW_POSTS(state) {
      let posts = [...state.new_posts, ...state.posts];
      console.log(posts);
      posts = _.orderBy(posts, ["created_at"], ["desc"]);
      console.log(posts);
      state.posts = posts;
      state.new_posts = [];
    }
  },

  actions: {
    cleanFeedPosts({ commit }) {
      commit(types.CLEAN_FEED_POSTS);
    },

    setFeedPosts({ commit }, posts) {
      commit(types.SET_FEED_POSTS, posts);
    },

    addFeedPost({ commit }, post) {
      commit(types.ADD_FEED_POST, post);
    },

    appendFeedPosts({ commit }, posts) {
      commit(types.APPEND_FEED_POSTS, posts);
    },

    removeFeedPost({ commit }, post) {
      commit(types.REMOVE_FEED_POST, post);
    },

    setFeedPost({ commit }, post, newPost) {
      commit(types.SET_FEED_POST, { post: post, newPost: newPost });
    },
    add_new_post({ commit }, post) {
      commit("ADD_NEW_POST", post);
    },
    prepend_new_posts({ commit }) {
      commit("PREPEND_NEW_POSTS");
    }
  }
};
