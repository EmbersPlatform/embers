import {define} from "wicked-elements";
import * as Reports from "~js/lib/moderation/reports";
import * as Posts from "~js/lib/posts";
import status_toasts from "~js/managers/status_toasts";
import { get_tags } from "../post/dom";
import * as Sets from "~js/lib/utils/sets";
import * as Fetch from "~js/lib/utils/fetch";
import { confirm } from "~js/managers/dialog";

define("[post-report-summary]", {
  // @ts-ignore
  onClick(event) {
    const {target} = event;
    switch(target.dataset.action) {
      case "resolve": {
        resolve_report(this);
        break;
      }
      case "flag_nsfw": {
        flag_nsfw(this);
        break;
      }
      case "disable": {
        disable_post(this);
        break;
      }
    }
  }
})

const resolve_report = host => {
  Reports.resolve(host.element.dataset.postId)
  .then(res => {
    if(res.tag === "Success") {
      host.element.remove();
      status_toasts.add({content: "Reporte resuelto", duration: 1000})
    } else {
      status_toasts.add({content: "No se pudo resolver el reporte"})
      console.error(res);
    }
  })
}

const flag_nsfw = async (host) => {
  const res = await Fetch.put(`/moderation/reports/post/${host.element.dataset.postId}/nsfw_and_resolve`)
  switch(res.tag) {
    case "Success": {
      host.element.remove();
      status_toasts.add({content: "Reporte resuelto", duration: 1000})
      break;
    }
    default: {
      status_toasts.add({content: "No se pudo resolver el reporte"})
      console.error(res);
      break;
    }
  }
}

const disable_post = async (host) => {
  const confirmation = await confirm({title: "Eliminar la publicacion?"})
  if(!confirmation) return;
  const res = await Fetch.put(`/moderation/reports/post/${host.element.dataset.postId}/disable_and_resolve`)
  switch(res.tag) {
    case "Success": {
      host.element.remove();
      status_toasts.add({content: "Reporte resuelto", duration: 1000})
      break;
    }
    default: {
      status_toasts.add({content: "No se pudo resolver el reporte"})
      console.error(res);
      break;
    }
  }
}
