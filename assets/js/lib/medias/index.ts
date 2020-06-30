import * as Fetch from "~js/lib/utils/fetch";
const {FetchResults} = Fetch;
import type {NetResult} from "~js/lib/utils/fetch"

interface MediaMetadata {
  preview_url: string
}

export interface Media {
  id: string,
  metadata: MediaMetadata,
  temp: boolean,
  timestamp: number,
  type: "image" | "gif" | "video",
  url: string
}

export async function upload(file): Promise<NetResult<Media, any>> {
  const body = formdata_from_file(file)
  const res = await Fetch.post("/medias", body)

  switch(res.tag) {
    case "Success": {
      return FetchResults.Success(await res.value.json() as Media)
    }
    case "Error": {
      if(res.value.status !== 422) return FetchResults.Error(res.value.statusText);
      const errors = await res.value.json();
      return FetchResults.Error(errors);
    }
    case "NetworkError": {
      return FetchResults.NetworkError()
    }
  }
}

function formdata_from_file(file) {
  let formdata = new FormData();
  formdata.append("file", file);
  return formdata;
}
