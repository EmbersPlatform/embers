const state = {
  title: 'Embers'
}

const mutations = {
  UPDATE(state, title) {
    state.title = title;
  }
}

const actions = {
  update({
    commit
  }, title) {
    commit("UPDATE", title);
  }
}

const getters = {
  title(state, _getters, _rootState, rootGetters) {
    const unseen_notifs = rootGetters['notifications/unseen'];
    if (unseen_notifs > 0) {
      return `(${unseen_notifs}) ${state.title}`;
    }
    return state.title;
  }
}

export default {
  namespaced: true,
  state,
  mutations,
  actions,
  getters
}
