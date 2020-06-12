import * as Fetch from "~js/lib/utils/fetch";
import type {NetResult, PaginationPage} from "~js/lib/utils/fetch";

const {FetchResults} = Fetch;

interface GetNotificationsParams {
  after?: string,
  before?: string,
  limit?: number
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
