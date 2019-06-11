import EventBus from '@/lib/event_bus';

const callbacks = {
  notification(payload) {
    EventBus.$emit("new_notification", payload);
  },
  new_chat_message(payload) {
    EventBus.$emit("new_chat_message", payload);
  },
  conversation_read(payload) {
    EventBus.$emit("conversation_read", payload);
  },
  chat_typing(payload) {
    EventBus.$emit("chat_typing", payload);
  }
}

export default {
  init(socket, user_id) {
    const channel = socket.channel(`user:${user_id}`, {});
    channel.join();

    channel.on("notification", callbacks.notification);

    channel.on("new_chat_message", callbacks.new_chat_message);

    channel.on("conversation_read", callbacks.conversation_read);

    channel.on("chat_typing", callbacks.chat_typing);

    return channel;
  }
}
