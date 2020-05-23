import * as Fetch from "#/lib/utils/fetch";

export async function get(options = {}){
  const params = {before: options.before}
  const res = await Fetch.get("/timeline", {params})

  return res.match({
    Success: async response => {
      const metadata = JSON.parse(response.headers.get("embers-page-metadata"));
      const activities = await response.text()
      const page = {
        activities,
        last_page: metadata.last_page,
        next: metadata.next
      }

      return Fetch.FetchResult.Success(page);
    },
    Error: async response => {
      const errors = await response.json();
      return Fetch.FetchResult.Error(errors);
    },
    NetworkError: () => {
      return Fetch.FetchResult.NetworkError
    }
  })
}
