import * as Fetch from "~js/lib/utils/fetch";
const {FetchResults} = Fetch;
import type {NetResult} from "~js/lib/utils/fetch"

const url_regex_test = /(?:(?:(?:https?|ftp):)?\/\/)(?:\S+(?::\S*)?@)?(?:(?!(?:10|127)(?:\.\d{1,3}){3})(?!(?:169\.254|192\.168)(?:\.\d{1,3}){2})(?!172\.(?:1[6-9]|2\d|3[0-1])(?:\.\d{1,3}){2})(?:[1-9]\d?|1\d\d|2[01]\d|22[0-3])(?:\.(?:1?\d{1,2}|2[0-4]\d|25[0-5])){2}(?:\.(?:[1-9]\d?|1\d\d|2[0-4]\d|25[0-4]))|(?:(?:[a-z0-9\u00a1-\uffff][a-z0-9\u00a1-\uffff_-]{0,62})?[a-z0-9\u00a1-\uffff]\.)+(?:[a-z\u00a1-\uffff]{2,}\.?))(?::\d{2,5})?(?:[/?#]\S*)?/i;
const url_regex_match = /(?:(?:(?:https?|ftp):)?\/\/)(?:\S+(?::\S*)?@)?(?:(?!(?:10|127)(?:\.\d{1,3}){3})(?!(?:169\.254|192\.168)(?:\.\d{1,3}){2})(?!172\.(?:1[6-9]|2\d|3[0-1])(?:\.\d{1,3}){2})(?:[1-9]\d?|1\d\d|2[01]\d|22[0-3])(?:\.(?:1?\d{1,2}|2[0-4]\d|25[0-5])){2}(?:\.(?:[1-9]\d?|1\d\d|2[0-4]\d|25[0-4]))|(?:(?:[a-z0-9\u00a1-\uffff][a-z0-9\u00a1-\uffff_-]{0,62})?[a-z0-9\u00a1-\uffff]\.)+(?:[a-z\u00a1-\uffff]{2,}\.?))(?::\d{2,5})?(?:[/?#]\S*)?/gi;

export const clipboard_has_link = event => {
  const text = event.clipboardData.getData("text");
  return text_has_link(text);
}

export function text_has_link(string) {
  return url_regex_test.test(string);
}

export function extract_links(string) {
  return string.match(url_regex_match);
}

export interface Link {
  id: string,
  html: string
}

type LinkResponse = NetResult<Link, Object>

export async function process(link): Promise<LinkResponse> {
  const res = await Fetch.post("/links", {url: link}, {type: "json"});
  switch(res.tag) {
    case "Success": {
      const link_id = res.value.headers.get("embers-link-id");
      const r = FetchResults.Success({
        id: link_id,
        html: await res.value.text()
      });
      return r;
    }
    case "Error": {
      return FetchResults.Error(await res.value.json())
    }
    case "NetworkError": {
      return Promise.resolve(FetchResults.NetworkError())
    }
  }
}
