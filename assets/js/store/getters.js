export const feed = state => state.feed.posts;
export const user = state => state.auth.user;
export const settings = state => state.settings.settings;
export const userMutuals = state => state.userMutuals.mutuals;

export const newActivity = state => state.newActivity;

export const title = (state, getters, root_state, root_getters) => {
  let title = state.originalTitle;
  if (state.chat.new_message || state.chat.unread_messages > 0) {
    title = "● " + title;
  }
  if (root_getters["notifications/unseen"] > 0) {
    title = `(${root_getters["notifications/unseen"]}) ` + title;
  }

  return title;
};

export const tags = state => state.auth.tags;
