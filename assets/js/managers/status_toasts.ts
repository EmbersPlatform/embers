import { ToastData } from "~js/components/toasts/toast-notification.comp";
import ToastZone from "~js/components/toasts/toast-zone.comp";

let status_toasts: ToastZone;

const register = () => {
  status_toasts = document.createElement("toast-zone") as ToastZone;
  status_toasts.setAttribute("top-center", "");
  status_toasts.id = "status-toasts";
  document.body.append(status_toasts);
  window["status_toasts"] = status_toasts;
};

document.addEventListener("DOMContentLoaded", register);

export default {
  add: (opts: ToastData) => {
    if (!status_toasts) register();

    status_toasts.add(opts);
  },
};
