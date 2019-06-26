export default {
  UPDATE(state, notifications) {
    state.notifications = notifications;
  },
  ADD(state, notification) {
    state.notifications = [notification, ...state.notifications];
  },
  APPEND(state, notifications) {
    state.notifications.push(...notifications);
  },
  REMOVE(state, id) {
    state.notifications = state.notifications.filter(o => o.id != id);
  },
  READ(state, id) {
    state.notifications = state.notifications.map(o => {
      if (o.id == id) o.status = 2;
      return o;
    });
  },
  UNREAD(state, id) {
    state.notifications = state.notifications.map(o => {
      if (o.id == id) o.status = 2;
      return o;
    });
  },
  MARK_AS_SEEN(state) {
    state.notifications = state.notifications.map(o => {
      if (o.status == 0) o.status = 1;
      return o;
    });
  }
};
