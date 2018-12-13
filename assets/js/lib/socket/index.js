import { Socket } from "phoenix";

let socket = new Socket("/socket", { params: { token: window.user_token } });
socket.connect();

export default socket;
