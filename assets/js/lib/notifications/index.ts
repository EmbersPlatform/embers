import * as Fetch from "~js/lib/utils/fetch";
import type { NetResult, PaginationPage } from "~js/lib/utils/fetch";
import s from "flyd";
import * as Channel from "~js/lib/socket/channel";

import * as Application from "~js/lib/application";
import { dgettext } from "../gettext";

const { FetchResults } = Fetch;

const user = Application.get_user();

export const unseen_count = s.stream(
  Application.app_data.unseen_notifications_count
);

export const countable_types = ["comment", "mention", "follow"];

Channel.subscribe(`user:${user.id}`, "notification", (notification) => {
  if (!notification.ephemeral) unseen_count(unseen_count() + 1);
});

Channel.subscribe(`user:${user.id}`, "notification_read", () => {
  unseen_count(unseen_count() - 1);
});

Channel.subscribe(`user:${user.id}`, "all_notifications_read", () => {
  unseen_count(0);
});

interface GetNotificationsParams {
  after?: string;
  before?: string;
  limit?: number;
  mark_as_seen?: boolean;
}
export const get = async (
  params: GetNotificationsParams = {}
): Promise<NetResult<PaginationPage, Object>> => {
  const res = await Fetch.get(`/notifications`, { params });
  switch (res.tag) {
    case "Success": {
      const page = await Fetch.parse_pagination(res.value);
      return FetchResults.Success(page);
    }
    case "Error": {
      return FetchResults.Error(await res.value.json());
    }
    case "NetworkError": {
      return FetchResults.NetworkError();
    }
  }
};

export const read = async (id) => {
  return Fetch.put(`/notifications/${id}`);
};

export const render_text = (notification): string => {
  switch (notification.type) {
    case "comment": {
      const from = `<strong>${notification.from}</strong>`;
      const post = `<strong>post</strong>`;
      return dgettext("notifications", `%1 replied to your %2`, from, post);
    }
    case "mention": {
      const from = `<strong>${notification.from}</strong>`;
      const post = `<strong>post</strong>`;
      return dgettext("notifications", `%1 mentioned you in a %2`, from, post);
    }
    case "follow": {
      const from = `<strong>${notification.from}</strong>`;
      return dgettext("notifications", `%1 is following you`, from);
    }
    case "post_reaction": {
      const from = `<strong>${notification.from}</strong>`;
      return dgettext("notifications", "%1 reacted to your post", from);
    }
    default:
      return notification.type;
  }
};

export const render_url = (notification) => {
  switch (notification.type) {
    case "comment":
    case "mention":
      return `/post/${notification.source}`;
    case "follow":
      return `/@${notification.from}`;
    default:
      return "";
  }
};
