import * as Fetch from "~js/lib/utils/fetch";
const {FetchResults} = Fetch;

type UpdateCoverResult = Promise<
  | Fetch.NetResult<string, any>
  >
export async function update_cover(blob: Blob): UpdateCoverResult {
  const body = Fetch.formdata_from_file(blob, "cover");
  const result = await Fetch.post("/settings/profile/update_cover", body);

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

type Avatar =
  {
    small: string,
    medium: string,
    big: string
  }
type UpdateAvatarResult = Promise<
  | Fetch.NetResult<Avatar, any>
  >
export async function update_avatar(blob: Blob): UpdateAvatarResult {
  const body = Fetch.formdata_from_file(blob, "avatar");
  const result = await Fetch.post("/settings/profile/update_avatar", body);

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

export async function update_profile(attrs) {
  const result = await Fetch.patch("/settings/profile/update_profile", attrs, {type: "json"});

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
