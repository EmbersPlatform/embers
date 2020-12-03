import * as Fetch from "~js/lib/utils/fetch";

export const set_subscription_level = async (tag_id: string, level: number) => {
  const res = await Fetch.post(`tags/${tag_id}/sub`, {level}, {type: "json"});

  return res.tag === "Success";
}

export const unsubscribe = async (tag_id: string) => {
  const res = await Fetch.delet(`tags/${tag_id}/sub`, {type: "json"});

  return res.tag === "Success";
}
