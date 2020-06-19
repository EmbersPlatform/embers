// @ts-check

import {
  Socket
} from "phoenix";
import * as Application from "~js/lib/application";

const connect = function () {
  let socket = new Socket("/socket", {
    params: {
      token: Application.get_ws_token()
    }
  });
  socket.connect();

  return socket;
}


export default connect;
