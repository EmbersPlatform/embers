import * as Fetch from "~js/lib/utils/fetch";
import type {NetResult, PaginationPage} from "~js/lib/utils/fetch";

interface GetTimelineOptions {
  before?: string
}
export async function get(options: GetTimelineOptions = {}): Promise<NetResult<PaginationPage, Object>>{
  const params = {before: options.before, entries: true}
  const res = await Fetch.get("/discover", {params})
  switch(res.tag) {
    case "Success": {
      const page = await Fetch.parse_pagination(res.value)
      return Fetch.FetchResults.Success(page);
    }
    case "Error": {
      const errors = await res.value.json();
      return Fetch.FetchResults.Error(errors);
    }
    case "NetworkError": {
      return Fetch.FetchResults.NetworkError()
    }
  }
}
