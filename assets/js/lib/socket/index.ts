import * as Application from "~js/lib/application";

import {
  Socket
} from "phoenix";
import socket from "./socket";
import LiveSocket from "phoenix_live_view"

import Feed from "./channels/feed";
import User from "./channels/user";

let user_id = Application.is_authenticated() ? Application.get_user().id : null;

let channel_socket = socket();
let feed_channel = Feed.init(channel_socket, user_id);
let user_channel = User.init(channel_socket, user_id);

if (user_id) {
  const PhxCustomEvent = {
    mounted() {
      const attrs = this.el.attributes;
      for (var i = 0; i < attrs.length; i++) {
        if (/^phx-custom-event-/.test(attrs[i].name)) {
          const eventName = attrs[i].name.replace("phx-custom-event-", "");
          const phxEvent = attrs[i].value
          this.el.addEventListener(eventName, ({ detail }) => {
            this.pushEvent(phxEvent, detail);
          });
        }
      }
    }
  }

  let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
  let liveSocket = new LiveSocket("/live", Socket, {
    params: {
      _csrf_token: csrfToken,
      token: Application.get_ws_token()
    },
    hooks: {
      PhxCustomEvent
    }
  });

  // Connect if there are any LiveViews on the page
  liveSocket.connect()

  // Expose liveSocket on window for web console debug logs and latency simulation:
  // >> liveSocket.enableDebug()
  // >> liveSocket.enableLatencySim(1000)
  // The latency simulator is enabled for the duration of the browser session.
  // Call disableLatencySim() to disable:
  // >> liveSocket.disableLatencySim()
  // @ts-ignore
  window.liveSocket = liveSocket
}

export default {
  socket: channel_socket,
  channels: {
    feed: feed_channel,
    user: user_channel,
  },
};
