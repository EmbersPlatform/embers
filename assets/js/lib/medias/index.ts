import * as Fetch from "~js/lib/utils/fetch";
const {FetchResults} = Fetch;
import type {NetResult} from "~js/lib/utils/fetch"


export async function upload(file) {
  const body = formdata_from_file(file)
  const res = await Fetch.post("/medias", body)

  switch(res.tag) {
    case "Success": {
      return FetchResults.Success(await res.value.json())
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
