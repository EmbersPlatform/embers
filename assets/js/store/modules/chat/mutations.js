import * as types from "./mutation-types";

import _ from "lodash";

const mutations = {
  [types.UPDATE_CONVERSATIONS](state, conversations) {
    state.conversations = conversations;
  },
  [types.UPDATE_UNREAD_MESSAGES_COUNT](state, count) {
    state.unread_messages = count;
  },
  [types.ADD_CONVERSATION](state, conversation) {
    state.conversations.push(conversation);
  },

  [types.UPDATE_CONVERSATION](state, conversation) {
    state.conversation = conversation;
  },
  [types.NEW_CONVERSATION_MESSAGE](state, conversationId) {
    let index = _.findIndex(state.conversations, o => {
      return o.id == conversationId;
    });
    state.conversations[index].unread++;
  },
  [types.MARK_CONVERSATION_AS_READ](state, conversationId) {
    let index = _.findIndex(state.conversations, o => {
      return o.id == conversationId;
    });
    state.unread_messages -= state.conversations[index].unread;
    state.conversations[index].unread = 0;
  },

  [types.UPDATE_MESSAGES](state, messages) {
    state.messages = messages;
  },
  [types.PUSH_MESSAGES](state, messages) {
    state.messages.push(...messages);
  },
  [types.REMOVE_MESSAGE](state, messageId) {
    // TODO
  },
  [types.ADD_MESSAGE](state, message) {
    if (state.messages === null) {
      state.messages = [];
    }
    state.messages = _.concat([message], state.messages);
  },

  [types.NEW_MESSAGE](state, value) {
    state.new_message = value;
  },

  [types.TOGGLE_NEW_CHAT_MODAL](state, value) {
    state.show_new_chat_modal = value;
  },

  SET_ONLINE_FRIENDS(state, value) {
    state.online_friends = value;
  }
};

export default mutations;
