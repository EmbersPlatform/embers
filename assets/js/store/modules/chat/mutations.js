import _ from "lodash";

const mutations = {
  READ_CONVERSATION_WITH(state, party) {
    state.unread_conversations = state.unread_conversations.filter(c => c != party)
  },
  ADD_UNREAD_CONVERSATION_WITH(state, party) {
    state.unread_conversations.push(party)
    state.unread_conversations = _.uniq(state.unread_conversations)
  },
  SET_UNREAD_CONVERSATIONS(state, conversations) {
    state.unread_conversations = conversations;
  },
  TOGGLE_NEW_CHAT_MODAL(state, value) {
    state.show_new_chat_modal = value;
  },
  SET_ONLINE_FRIENDS(state, value) {
    state.online_friends = value;
  }
};

export default mutations;
