import EventBus from '@/lib/event_bus';

const callbacks = {
  notification(payload) {
    EventBus.$emit("new_notification", payload);
  }
}

export default {
  init(socket, user_id) {
    const channel = socket.channel(`user:${user_id}`, {});
    channel.join();

    channel.on("notification", callbacks.notification);

    return channel;
  }
}
