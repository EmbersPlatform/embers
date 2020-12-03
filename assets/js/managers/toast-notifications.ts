import { html } from "uhtml";
import * as Application from "~js/lib/application";
import * as Channel from "~js/lib/socket/channel";
import * as GeneralToasts from "./general_toasts";
import { render_text, render_url } from "~js/lib/notifications";

const interpolate = (string: string) => html([string] as any);

const user = Application.get_user();

const show_toast_notification = (notification) => {
  switch (notification.type) {
    case "post_reaction": {
      GeneralToasts.add({ content: render_reaction(notification) });
      break;
    }
    default: {
      GeneralToasts.add({ content: render_generic(notification) });
      break;
    }
  }
};

const render_reaction = (notification) => {
  const reaction_icon = `/svg/reactions/${notification.reaction}.svg`;
  return html.node`
    <a href=${render_url(
      notification
    )} class="notification-content notification--reaction">
      <img class="icon" src=${notification.avatar} />
      <img class="reaction-icon" src=${reaction_icon} />
      <span class="text">${interpolate(render_text(notification))}</span>
    </a>
  `;
};

const render_generic = (notification) => html.node`
  <a href=${render_url(notification)} class="notification-content">
    ${
      notification.icon
        ? html`<img class="icon" src=${notification.avatar} />`
        : ``
    }
    <span class="text">${interpolate(render_text(notification))}</span>
  </a>
`;

Channel.subscribe(`user:${user.id}`, "notification", show_toast_notification);
