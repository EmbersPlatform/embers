export default {
  UPDATE(state, notifications) {
    state.notifications = notifications;
  },
  ADD(state, notification) {
    state.notifications = [notification, ...state.notifications];
  },
  REMOVE(state, id) {
    state.notifications = state.notifications.filter(o => o.id != id);
  },
  READ(state, id) {
    state.notifications = state.notifications.map(o => {
      if (o.id == id) o.read = true;
      return o;
    });
  },
  UNREAD(state, id) {
    state.notifications = state.notifications.map(o => {
      if (o.id == id) o.read = false;
      return o;
    });
  }
};
