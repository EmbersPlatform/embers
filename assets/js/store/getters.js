export const feed = state => state.feed.posts;
export const user = state => state.auth.user;
export const settings = state => state.settings.settings;
export const userMutuals = state => state.userMutuals.mutuals;
export const notifications = state => state.notifications.notifications;
export const notifications_count = state => state.notifications.notifications_count;

export const can = state => (permission) => {
  if (state.auth.user.permissions.includes('any')) return true
  return state.auth.user.permissions.includes(permission)
}

export const newActivity = state => state.newActivity;

export const title = state => {
  let title = state.originalTitle;
  if (state.chat.new_message || state.chat.unread_messages > 0) {
    title = '● ' + title;
  }
  if (state.notifications.notifications_count > 0) {
    title = `(${state.notifications.notifications_count}) ` + title;
  }

  return title;
}
