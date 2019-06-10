const actions = {
  read_conversation_with({
    commit
  }, party) {
    commit("READ_CONVERSATION_WITH", party);
  },
  add_unread_conversation_with({
    commit
  }, party) {
    commit("ADD_UNREAD_CONVERSATION_WITH", party)
  },
  set_unread_conversations({
    commit
  }, conversations) {
    commit("SET_UNREAD_CONVERSATIONS", conversations)
  },
  toggleNewChatModal({
    commit
  }, value) {
    commit("TOGGLE_NEW_CHAT_MODAL", value);
  },
  set_online_friends({
    commit
  }, value) {
    commit("SET_ONLINE_FRIENDS", value);
  }
};

export default actions;
