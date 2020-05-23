import {tags} from "stags";
import * as Fetch from "/js/lib/utils/fetch";

const {FetchResult: Result} = Fetch;

const Errors = tags("Errors", [
  "TooLarge"
])

export async function upload(file) {
  const body = formdata_from_file(file)
  const res = await Fetch.post("/medias", body)

  return res.match({
    Success: async response => Result.Success(await response.json()),
    Error: async response => {
      if(response.status !== 422) return Result.Error(response.statusText);
      const errors = await response.json();
      return Result.Error(errors);
    },
    NetworkError: () => Result.NetworkError()
  })
}

function formdata_from_file(file) {
  let formdata = new FormData();
  formdata.append("file", file);
  return formdata;
}
