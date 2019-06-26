import Vue from 'vue';
import Vuex from 'vuex';

import auth from './modules/auth';
import feed from './modules/feed';

import userMutuals from './modules/user.mutuals';
import notifications from './modules/notifications/index';
import settings from './modules/settings';
import chat from './modules/chat';
import tag from './modules/tag';
import title from './modules/title'
import media_slides from './modules/media_slides';
import * as getters from './getters';

Vue.use(Vuex);

export default new Vuex.Store({
  state: {
    appData: {},
    userProfile: {},
    newActivity: 0,
    show_navigation: true
  },

  modules: {
    auth,
    feed,
    userMutuals,
    notifications,
    settings,
    chat,
    tag,
    title,
    media_slides
  },
  mutations: {
    SET_APP_DATA(state, data) {
      state.appData = data;
    },

    SET_USER_PROFILE(state, user) {
      state.userProfile = user;
    },
    NEW_ACTIVITY(state) {
      state.newActivity += 1;
    },
    RESET_ACTIVITY(state) {
      state.newActivity = 0;
    },
    TOGGLE_NAVIGATION(state, value) {
      state.show_navigation = value;
    }
  },

  actions: {
    setAppData({
      commit
    }, appData) {
      commit('SET_APP_DATA', appData);
    },

    setUserProfile({
      commit
    }, user) {
      commit('SET_USER_PROFILE', user);
    },
    newActivity({
      commit
    }) {
      commit('NEW_ACTIVITY');
    },
    resetNewActivity({
      commit
    }) {
      commit('RESET_ACTIVITY');
    },
    toggle_navigation({
      commit
    }, value) {
      commit("TOGGLE_NAVIGATION", value)
    }
  },

  getters
});
