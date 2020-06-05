import * as Fetch from "~js/lib/utils/fetch";
const {FetchResults} = Fetch;
import type {NetResult, PaginationPage} from "~js/lib/utils/fetch"
import * as Validations from "./validations";

export {Validations};

export interface CreatePostOptions {
  params?: {
    as_thread?: boolean
  }
}
export async function create(attrs, options: CreatePostOptions): Promise<NetResult<string, Object>> {
  let res = await Fetch.post("/post", attrs, { type: "json", accept: "html", ...options });
  switch(res.tag) {
    case "Success": {
      return FetchResults.Success(await res.value.text())
    }
    case "Error": {
      return FetchResults.Error(await res.value.json())
    }
    case "NetworkError": {
      return FetchResults.NetworkError()
    }
  }
}

export async function delet(post_id): Promise<NetResult<void, Object>> {
  let res = await Fetch.delet(`/post/${post_id}`, { type: "json" })
  switch(res.tag) {
    case "Success": {
      return FetchResults.Success()
    }
    case "Error": {
      return FetchResults.Error(await res.value.json())
    }
    case "NetworkError": {
      return FetchResults.NetworkError()
    }
  }
}


export interface GetRepliesParams {
  after?: string,
  before?: string,
  limit?: number,
  order?: string,
  skip_first?: boolean,
  as_thread?: boolean,
  replies?: number
}
export async function get_replies(post_id: string, params: GetRepliesParams): Promise<NetResult<PaginationPage, Object>> {
  let res = await Fetch.get(`/post/${post_id}/replies`, { type: "json", params })
  switch(res.tag) {
    case "Success": {
      const page = await Fetch.parse_pagination(res.value);
      return FetchResults.Success(page);
    }
    case "Error": {
      return FetchResults.Error(await res.value.json())
    }
    case "NetworkError": {
      return FetchResults.NetworkError()
    }
  }
}

export async function add_reaction(post_id, reaction) {
  let res = await Fetch.post(`/post/${post_id}/reactions`, {name: reaction}, { type: "json" })
  switch(res.tag) {
    case "Success": {
      return FetchResults.Success(await res.value.text())
    }
    case "Error": {
      return FetchResults.Error(await res.value.json())
    }
    case "NetworkError": {
      return FetchResults.NetworkError()
    }
  }
}

export async function remove_reaction(post_id, reaction) {
  let res = await Fetch.delet(`/post/${post_id}/reactions/${reaction}`, { type: "json" })
  switch(res.tag) {
    case "Success": {
      return FetchResults.Success(await res.value.text())
    }
    case "Error": {
      return FetchResults.Error(await res.value.json())
    }
    case "NetworkError": {
      return FetchResults.NetworkError()
    }
  }
}

export async function get_reactions(post_id, reaction, after): Promise<NetResult<PaginationPage, any>> {
  let params = {} as {after?: string};
  if(after) params.after = after;
  let res = await Fetch.get(`/post/${post_id}/reactions/${reaction}`, {type: "json", params})
  switch(res.tag) {
    case "Success": {
      const page = await Fetch.parse_pagination(res.value);
      return FetchResults.Success(page);
    }
    case "Error": {
      return FetchResults.Error(await res.value.json())
    }
    case "NetworkError": {
      return FetchResults.NetworkError()
    }
  }
}

export type ReactionOverview = {
  name: string,
  count: number
}
export async function get_reactions_overview(post_id: string): Promise<NetResult<ReactionOverview[], Object>> {
  let res = await Fetch.get(`/post/${post_id}/reactions/overview`, {type: "json"})
  switch(res.tag) {
    case "Success": {
      return FetchResults.Success(await res.value.json())
    }
    case "Error": {
      return FetchResults.Error(await res.value.json())
    }
    case "NetworkError": {
      return FetchResults.NetworkError()
    }
  }
}

export async function update_tags(params) {
  let res = await Fetch.post(`/moderation/post/update_tags`, params, {type: "json"});
  switch(res.tag) {
    case "Success": {
      return FetchResults.Success(await res.value.text())
    }
    case "Error": {
      return FetchResults.Error(await res.value.json())
    }
    case "NetworkError": {
      return FetchResults.NetworkError()
    }
  }
}

export async function add_to_favorites(post_id) {
  let res = await Fetch.post(`/favorites/${post_id}`, {}, {type: "json"});
  switch(res.tag) {
    case "Success": {
      return FetchResults.Success()
    }
    case "Error": {
      return FetchResults.Error(await res.value.json())
    }
    case "NetworkError": {
      return FetchResults.NetworkError()
    }
  }
}

export async function remove_from_favorites(post_id) {
  let res = await Fetch.delet(`/favorites/${post_id}`, {type: "json"});
  switch(res.tag) {
    case "Success": {
      return FetchResults.Success()
    }
    case "Error": {
      return FetchResults.Error(await res.value.json())
    }
    case "NetworkError": {
      return FetchResults.NetworkError()
    }
  }
}
