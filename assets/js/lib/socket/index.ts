import * as Application from "~js/lib/application";

import Socket from './socket';
import Feed from './channels/feed';
import User from './channels/user';

let user_id = Application.is_authenticated() ? Application.get_user().id : null;

const socket = Socket();
const feed_channel = Application.is_authenticated() ? Feed.init(socket, user_id) : null;
const user_channel = Application.is_authenticated() ? User.init(socket, user_id) : null;

export default {
  socket: socket,
  channels: {
    feed: feed_channel,
    user: user_channel
  }
};
