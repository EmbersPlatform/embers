import * as Fetch from "~js/lib/utils/fetch";
const {FetchResults} = Fetch;

const max_file_size = 5 * 1024 * 1024 // 5MB
export const allowed_media_types = [
  "image/png",
  "image/jpeg",
  "image/jpg",
  "image/gif",
  "video/mp4",
  "video/webm"
]

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

type MediaUploadResult<S, E> = Promise<
  | Fetch.NetResult<S, E>
  | {tag: "ValidationError", value: string}
  >

export async function upload(file): MediaUploadResult<Media, any> {
  const validation_result = validate(file);
  if(validation_result !== null) {
    return {tag: "ValidationError", value: validation_result}
  }
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

export function validate(file: File): string | null {
  if(file.size > max_file_size) {
    return `The max file size if 5MB`;
  }
  if(!allowed_media_types.includes(file.type)) {
    return "The file type is not allowed";
  }
  return null;
}

function formdata_from_file(file) {
  let formdata = new FormData();
  formdata.append("file", file);
  return formdata;
}

