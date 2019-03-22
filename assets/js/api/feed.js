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
    return wrap(() =>
      axios.get(`${config.prefix}/feed/${name}`, {params: params})
    );
  }
};
