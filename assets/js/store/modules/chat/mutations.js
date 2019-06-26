import _ from "lodash";

const mutations = {
  READ_CONVERSATION_WITH(state, party) {
    state.unread_conversations = state.unread_conversations.filter(c => c.party != party)
  },
  ADD_UNREAD_CONVERSATION_WITH(state, party) {
    const index = _.findIndex(state.unread_conversations, x => x.party == party)
    if (index >= 0) {
      let conv = state.unread_conversations[index];
      conv.unread++;
      state.unread_conversations[index] = conv;
    } else {
      state.unread_conversations.push({
        party: party,
        unread: 1
      })
    }
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
