import axios from "axios";
import config from "./config";
import wrap from "./wrap";

export default {
  /**
   * Gets posts from the specified feed
   * @param name
   * @param before
   */
  get(name = "", params = {}) {
    let query = {};

    name = name ? "/" + name : "";

    if (typeof params.before !== "undefined" && !isNaN(params.before))
      query.before = params.before;

    if (typeof params.filters !== "undefined") {
      query.filters = params.filters;
    }

    if (typeof params.limit !== "undefined" && !isNaN(params.limit)) {
      query.limit = params.limit;
    }

    return wrap(() =>
      axios.get(`${config.prefix}/feed${name}`, { params: query })
    );
  }
};
