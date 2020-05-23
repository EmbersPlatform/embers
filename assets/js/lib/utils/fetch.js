import union from "/js/lib/utils/union";
import * as Url from "#/lib/url";

export const FetchResult = union("FetchResult", {
  Success: ["value"],
  Error: ["error"],
  NetworkError: []
})

FetchResult.prototype.match = function (clauses) { return this.cata(clauses) };

const default_headers = {
  'x-csrf-token': window.csrf_token,
}

// infer_result :: Object -> FetchResult
// Currently it just wraps the response in a FetchResult type
const infer_result = (response) => {
  if(response.ok) {
    return FetchResult.Success(response);
  }
  return FetchResult.Error(response);
}

// build_headers :: Object -> Object
const build_headers = (options) => {
  let headers = default_headers;

  let content_type = {
    "json": "application/json",
  }[options.type];
  if(content_type) headers["Content-Type"] = content_type;

 let accept = {
    "json": "application/json",
    "html": "text/html",
  }[options.accept];
  if(accept) headers["Accept"] = accept;

  return headers;
}

// perform_fetch :: (String, STring, Object) -> Promise FetchResult
const perform_fetch = async (url, method, options = {}) => {
  url = Url.build(url);

  // Add params to query string, if any
  if(options.params) {
    for(let key in options.params) {
      if(options.params[key]) // Ignore non truthy params like null or undefined. Possible bugs here?
        url.searchParams.append(key, options.params[key])
    }
  }

  let headers = build_headers(options);

  // Only json encode string bodies
  if(!(options.body instanceof FormData)) {
    options.body = JSON.stringify(options.body);
  }

  try {
    const res = await fetch(url.toString(), {method, headers, ...options})
    return infer_result(res, options);
  }
  catch(_e) {
    return FetchResult.NetworkError;
  }
}

// get :: (String, Object) -> Promise FetchResult
export const get = async (url, options) => {
  return await perform_fetch(url, "GET", options);
}

// post :: (String, Object) -> Promise FetchResult
export const post = async (url, body, options) => {
  return await perform_fetch(url, "POST", { body, ...options });
}

// post :: (String, Object) -> Promise FetchResult
export const delet = async (url, options) => {
  return await perform_fetch(url, "DELETE", options);
}

export const parse_pagination = async response => {
  const metadata = JSON.parse(response.headers.get("embers-page-metadata"));
  const body = await response.text()
  return {
    body,
    last_page: metadata.last_page,
    next: metadata.next
  }
}
