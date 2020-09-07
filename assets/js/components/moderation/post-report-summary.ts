import {define} from "wicked-elements";
import * as Reports from "~js/lib/moderation/reports";

define("[post-report-summary]", {
  // @ts-ignore
  onClick(event) {
    const {target} = event;
    if(target.matches("[resolve-trigger]"))
      Reports.resolve(this.element.dataset.postId)
      .then(res => {
        if(res.tag === "Success")
          this.element.remove()
        else
          console.error(res)
      })
  }
})
