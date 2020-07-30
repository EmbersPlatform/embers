import * as Url from "~js/lib/url";
import * as Application from "~js/lib/application";

export type NetResult<S, E> =
  | {tag: "Success", value: S}
  | {tag: "Error",  value: E}
  | {tag: "NetworkError"}

export const FetchResults = {
  Success: <S, E>(value?: S): NetResult<S, E> => ({tag: "Success", value: value}),
  Error: <E, S>(value: E): NetResult<S, E> => ({tag: "Error", value: value}),
  NetworkError: <S, E>(): NetResult<S, E> => ({tag: "NetworkError"})
}

const default_headers = {
  'x-csrf-token': Application.get_data().csrf_token,
}

// Currently it just wraps the response in a NetResult type
const infer_result = (response: Response): NetResult<Response, Response> => {
  if(response.ok) {
    return FetchResults.Success(response);
  }
  return FetchResults.Error(response);
}

const build_headers = (options) => {
  let headers = default_headers;

  if(options.type) {
    let content_type = {
      "json": "application/json",
    }[options.type];
    if(content_type) headers["Content-Type"] = content_type;
  }

  let accept = {
    "json": "application/json",
    "html": "text/html",
  }[options.accept];
  if(accept) headers["Accept"] = accept;

  return headers;
}

const perform_fetch = async (path: string, method: string, options: Object = {}): Promise<NetResult<Response, Response>> => {
  let url = Url.build(path);

  // Add params to query string, if any
  if(options["params"]) {
    for(let key in options["params"]) {
      if(options["params"][key]) // Ignore non truthy params like null or undefined. Possible bugs here?
        url.searchParams.append(key, options["params"][key])
    }
  }

  let headers = build_headers(options);

  // Only json encode string bodies
  if(!(options["body"] instanceof FormData)) {
    options["body"] = JSON.stringify(options["body"]);
  }

  try {
    const res = await fetch(url.toString(), {method, headers, ...options})
    // @ts-ignore clear Unpoly cache
    // window.up.proxy.clear()
    return infer_result(res);
  }
  catch(_e) {
    return FetchResults.NetworkError();
  }
}

export const get = async (url: string, options?: Object) => {
  return await perform_fetch(url, "GET", options);
}

export const post = async (url, body?, options?) => {
  return await perform_fetch(url, "POST", { body, ...options });
}

export const delet = async (url: string, options?: Object) => {
  return await perform_fetch(url, "DELETE", options);
}

export const put = async (url, body, options?) => {
  return await perform_fetch(url, "PUT", { body, ...options });
}

export const patch = async (url, body, options?) => {
  return await perform_fetch(url, "PATCH", { body, ...options });
}

export interface PaginationPage {
  body: string,
  last_page: boolean,
  next: string
}
export const parse_pagination = async (response: Response): Promise<PaginationPage> => {
  const metadata = JSON.parse(response.headers.get("embers-page-metadata"));
  const body = await response.text()
  return {
    body,
    last_page: metadata.last_page,
    next: metadata.next
  }
}

export const formdata_from_file = (file: Blob | File, key = "file") => {
  let formdata = new FormData();
  formdata.append(key, file);
  return formdata;
}
