import {define} from "wicked-elements";
import * as Reports from "~js/lib/moderation/reports";
import status_toasts from "~js/managers/status_toasts";
import * as Fetch from "~js/lib/utils/fetch";
import { confirm } from "~js/managers/dialog";
import { ban_user_dialog } from "./ban-user-dialog.comp";
import { dgettext } from "~js/lib/gettext";

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
      case "ban-user": {
        ban_user(this);
        break;
      }
      case "show_comments": {
        show_comments(this);
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
      resolved_report_toast();
    } else {
      failed_report_toast();
      console.error(res);
    }
  })
}

const flag_nsfw = async (host) => {
  const res = await Fetch.put(`/moderation/reports/post/${host.element.dataset.postId}/nsfw_and_resolve`)
  switch(res.tag) {
    case "Success": {
      host.element.remove();
      resolved_report_toast();
      break;
    }
    default: {
      failed_report_toast();
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
      resolved_report_toast();
      break;
    }
    default: {
      failed_report_toast();
      console.error(res);
      break;
    }
  }
}

const ban_user = async (host) => {
  ban_user_dialog.showModal(host.element.dataset.author);
}

const resolved_report_toast = () => {
  status_toasts.add({content: dgettext("moderation", "Report resolved"), duration: 1000});
}

const failed_report_toast = (error?: string) => {
  error
    ? status_toasts.add({content: error})
    : status_toasts.add({content: dgettext("moderation", "Could not resolve the report")})
}

const show_comments = host => {
  const dialog = host.element.querySelector("report-reasons-dialog");
  dialog?.showModal();
}
