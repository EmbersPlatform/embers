import * as Fetch from "~js/lib/utils/fetch";
const {FetchResults} = Fetch;

export async function update(attrs) {
  const result = await Fetch.patch("/settings", attrs, {type: "json"});

  switch(result.tag) {
    case "Success": {
      return FetchResults.Success(await result.value.json())
    }
    case "Error": {
      if(result.value.status !== 422) return FetchResults.Error(result.value.statusText);
      const errors = await result.value.json();
      return FetchResults.Error(errors);
    }
    case "NetworkError": {
      return FetchResults.NetworkError()
    }
  }
}
