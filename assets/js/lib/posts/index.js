import * as Fetch from "#/lib/utils/fetch";
import {FetchResult as Result} from "#/lib/utils/fetch";

export async function create(attrs, options) {
  let res = await Fetch.post("/post", attrs, { type: "json", accept: "html", ...options });
  return res.match({
    Success: async response =>  Result.Success(await response.text()),
    Error: async response =>  Result.Error(await response.json()),
    NetworkError: () => Result.NetworkError
  })
}

export async function delet(post_id) {
  let res = await Fetch.delet(`/post/${post_id}`, { type: "json" })
  return res.match({
    Success: () =>  Result.Success(true),
    Error: async response =>  Result.Error(await response.json()),
    NetworkError: () => Result.NetworkError
  })
}

export async function get_replies(post_id, params) {
  let res = await Fetch.get(`/post/${post_id}/replies`, { type: "json", params })
  return res.match({
    Success: async response =>  {
      const page = await Fetch.parse_pagination(response);
      return Result.Success(page);
    },
    Error: async response =>  Result.Error(await response.json()),
    NetworkError: () => Result.NetworkError
  })
}

export async function add_reaction(post_id, reaction) {
  let res = await Fetch.post(`/post/${post_id}/reactions`, {name: reaction}, { type: "json" })
  return res.match({
    Success: async response =>  Result.Success(await response.text()),
    Error: async response =>  Result.Error(await response.json()),
    NetworkError: () => Result.NetworkError
  })
}

export async function remove_reaction(post_id, reaction) {
  let res = await Fetch.delet(`/post/${post_id}/reactions/${reaction}`, { type: "json" })
  return res.match({
    Success: async response =>  Result.Success(await response.text()),
    Error: async response =>  Result.Error(await response.json()),
    NetworkError: () => Result.NetworkError
  })
}

export async function get_reactions(post_id, reaction, after) {
  let params = {};
  if(after) params.after = after;
  let res = await Fetch.get(`/post/${post_id}/reactions/${reaction}`, {type: "json", params})
  return res.match({
    Success: async response => {
      const page = await Fetch.parse_pagination(response);
      return Result.Success(page);
    },
    Error: async response =>  Result.Error(await response.json()),
    NetworkError: () => Result.NetworkError
  })
}

export async function get_reactions_overview(post_id) {
  let res = await Fetch.get(`/post/${post_id}/reactions/overview`, {type: "json"})
  return res.match({
    Success: async response => {
      return Result.Success(await response.json());
    },
    Error: async response =>  Result.Error(await response.json()),
    NetworkError: () => Result.NetworkError
  })
}
