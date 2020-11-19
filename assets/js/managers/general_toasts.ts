import { ToastData } from "~js/components/toasts/toast-notification.comp";
import ToastZone from "~js/components/toasts/toast-zone.comp";

let general_toasts: ToastZone;

const register = () => {
  general_toasts = document.createElement("toast-zone") as ToastZone;
  general_toasts.setAttribute("bottom-left", "");
  general_toasts.id = "general-toasts";
  document.body.append(general_toasts);
  window["general_toasts"] = general_toasts;
};

export const add = (options: ToastData) => {
  if (!general_toasts) register();

  general_toasts.add(options);
};

document.addEventListener("DOMContentLoaded", register);

export default general_toasts;
