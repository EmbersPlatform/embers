import * as types from './mutation-types';

const actions = {
	updateConversations({ commit }, conversations) {
		commit(types.UPDATE_CONVERSATIONS, conversations);
	},
	updateUnreadMessagesCount({ commit }, count, sync = true) {
		commit(types.UPDATE_UNREAD_MESSAGES_COUNT, count);
		if(sync) {
			window.localStorage.setItem('unreadMessagesCount', count);
		}
	},
	addConversation({ commit }, conversation) {
        commit(types.ADD_CONVERSATION, conversation);
    },

	updateConversation({ commit }, conversation) {
		commit(types.UPDATE_CONVERSATION, conversation);
	},
	newConversationMessage({ commit }, conversationId) {
		commit(types.NEW_CONVERSATION_MESSAGE, conversationId);
	},
	markConversationAsRead({ commit, state }, conversationId) {
		commit(types.MARK_CONVERSATION_AS_READ, conversationId);
	},

	updateMessages({ commit }, messages) {
		commit(types.UPDATE_MESSAGES, messages);
	},
	pushMessages({ commit }, messages) {
		commit(types.PUSH_MESSAGES, messages);
	},
	addMessage({ commit }, message) {
		commit(types.ADD_MESSAGE, message);
	},

	newMessage({ commit }, value = false, sync = true) {
		commit(types.NEW_MESSAGE, value);
		if(sync) {
			window.localStorage.setItem('newMessages', value);
		}
	},

	toggleNewChatModal({ commit }, value) {
		commit(types.TOGGLE_NEW_CHAT_MODAL, value);
	}
};

export default actions;