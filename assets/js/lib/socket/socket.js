import {
  Socket
} from "phoenix";

const connect = function () {
  let socket = new Socket("/socket", {
    params: {
      token: window.user_token
    }
  });
  socket.connect();

  return socket;
}


export default connect;
