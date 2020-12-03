import * as Fetch from "~js/lib/utils/fetch";

export async function resolve(post_id: string): Promise<Fetch.NetResult<true, Object>> {
  const res = await Fetch.put(`/moderation/reports/post/${post_id}`);
  switch(res.tag) {
    case "Success":
      return Fetch.FetchResults.Success(true);
    case "Error":
      return Fetch.FetchResults.Error(await res.value.json());
    case "NetworkError":
      return Fetch.FetchResults.NetworkError();
  }
}

export async function report_post(post_id: string, comments: string = "") {
  const res = await Fetch.post(`/reports/post/${post_id}`, {comments}, {type: "json"});
  switch(res.tag) {
    case "Success":
      return Fetch.FetchResults.Success(true);
    case "Error":
      return Fetch.FetchResults.Error(await res.value.json());
    case "NetworkError":
      return Fetch.FetchResults.NetworkError();
  }
}
