import axios from "axios";
import config from "./config";
import wrap from "./wrap";

import mixtapeMoe from "./external/mixtape.moe.js";

export default {
  /**
   * Audio attachment
   */
  audio: {
    /**
     * Uploads an audio
     *
     * @param blob
     */
    upload(blob) {
      return wrap(
        () =>
          new Promise((resolve, reject) => {
            console.log("uploading record...");
            var fileName = randomString() + ".webm";
            var file = new File([blob], fileName, {
              type: "video/webm"
            });
            let formData = new FormData();
            formData.append("file", file, fileName);

            const provider = mixtapeMoe;
            provider
              .upload(formData)
              .then(data => {
                axios
                  .post(`${config.prefix}/attachment/audio/sign`, {
                    provider: provider.name,
                    data
                  })
                  .then(resolve)
                  .catch(reject);
              })
              .catch(reject);
          })
      );
    }
  },

  parse(what) {
    return wrap(() =>
      axios.post(`${config.prefix}/attachment/parse`, { url: what })
    );
  }
};
