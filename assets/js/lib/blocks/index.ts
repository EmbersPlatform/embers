import * as Fetch from "~js/lib/utils/fetch";

export const block_user = (username: string) =>
  Fetch.post(`/blocks`, { name: username }, { type: "json" }).then((res) => {
    if (res.tag == "Success") return true;
    return false;
  });
