import * as Fetch from "~js/lib/utils/fetch";
import type {NetResult, PaginationPage} from "~js/lib/utils/fetch";
import s from "flyd";
import * as Channel from "~js/lib/socket/channel";

import * as Application from "~js/lib/application";

const {FetchResults} = Fetch;

const user = Application.get_user();

export const unseen_count = s.stream(Application.app_data.unseen_notifications_count);

Channel.subscribe(`user:${user.id}`, "notification", () => {
  unseen_count(unseen_count() + 1);
})

Channel.subscribe(`user:${user.id}`, "notification_read", () => {
  unseen_count(unseen_count() - 1);
})

Channel.subscribe(`user:${user.id}`, "all_notifications_read", () => {
  unseen_count(0);
})

interface GetNotificationsParams {
  after?: string,
  before?: string,
  limit?: number,
  mark_as_seen?: boolean
}
export const get = async (params: GetNotificationsParams = {}): Promise<NetResult<PaginationPage, Object>> => {
  const res = await Fetch.get(`/notifications`, {params});
  switch(res.tag) {
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
}

export const read = async (id) => {
  return Fetch.put(`/notifications/${id}`);
}
