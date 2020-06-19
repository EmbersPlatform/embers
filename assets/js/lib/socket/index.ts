import * as Application from "~js/lib/application";

import Socket from './socket';
import Feed from './channels/feed';
import User from './channels/user';

let user_id = Application.get_user().id;

const socket = Socket();
const feed_channel = Feed.init(socket, user_id);
const user_channel = User.init(socket, user_id);

export default {
  socket: socket,
  channels: {
    feed: feed_channel,
    user: user_channel
  }
};
