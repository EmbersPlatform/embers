import * as types from '../types';

export default {
	state: {
		posts: []
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

		setFeedPost({commit}, post, newPost) {
			commit(types.SET_FEED_POST, {post: post, newPost: newPost});
		}
	}
};