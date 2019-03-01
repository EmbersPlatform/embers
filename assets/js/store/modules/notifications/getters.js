export const notifications = state => state.notifications;

export const unseen = state => {
  return state.notifications.reduce((acc, n) => {
    if (n.status < 1) return acc + 1;
    return acc;
  }, 0);
};
