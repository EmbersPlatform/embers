import EventBus from '@/lib/event_bus';

const callbacks = {
  new_activity(payload) {
    const post = payload.post;
    post.new = true;
    EventBus.$emit("new_activity", post);
  }
}

export default {
  init(socket, user_id) {
    const channel = socket.channel(`feed:${user_id}`, {});
    channel.join();

    channel.on("new_activity", callbacks.new_activity);

    return channel;
  }
}
