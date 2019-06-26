export const unread_conversations_count = state => {
  if (!state.unread_conversations) return 0;
  return state.unread_conversations.length
}
