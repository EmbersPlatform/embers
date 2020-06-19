// @ts-check
import { BaseController } from "~js/lib/controller"

import PubSub from "pubsub-js";

import * as Sets from "~js/lib/utils/sets";
import * as Posts from "~js/lib/posts";
import * as Channel from "~js/lib/socket/channel";
import {gettext} from "~js/lib/gettext";

import type ModalDialog from "~js/components/dialog";

export const name = "post"

export default class extends BaseController {
  static targets = ["deleteDialog", "reactionsDialog", "reportDialog"]

  id: string

  pubsub_tokens: string[] = [];

  channel_topic: string
  channel_refs: number[] = [];

  connect() {
    let {id} = this.element.dataset;
    this.id = id;
    this.channel_topic = `post:${id}`;

    this.pubsub_tokens.push(
      PubSub.subscribe(`post:${id}.updated_tags`, this.update_tags.bind(this))
    );

    this._join_post_channel();
  }

  disconnect() {
    for(let token of this.pubsub_tokens) {
      PubSub.unsubscribe(token);
    }

    this._leave_post_channel();
  }

  confirm_delete() {
    if(this.has_target("deleteDialog")) {
      const dialog = this.get_target<ModalDialog>("deleteDialog");
      dialog.showModal();
    }
  }

  async delete() {
    const res = await Posts.delet(this.element.dataset.id)
    switch(res.tag) {
      case "Success": {
        // this.element.remove();
        const dialog = this.get_target<ModalDialog>("deleteDialog");
        dialog.close();
        break;
      }
      case "Error": {
        alert("Hubo un error al borrar el post");
        break;
      }
      case "NetworkError": {
        alert("Hubo un error al conectar con el servidor");
        break;
      }
    }
  }

  show_reactions_modal() {
    if(this.has_target("reactionsDialog")){
      const dialog = this.get_target<ModalDialog>("reactionsDialog");
      dialog.showModal();
    }
  }

  show_report_modal() {
    if(this.has_target("reportDialog")){
      const dialog = this.get_target<ModalDialog>("reportDialog");
      dialog.showModal();
    }
  }

  async toggle_nsfw() {
    let {id, tags: tags_string} = this.element.dataset;
    let tags = new Set(tags_string.split(" "));
    tags = Sets.filter(tags, Posts.Validations.valid_tag);

    if(Sets.has_insensitive(tags, "nsfw")) {
      tags = Sets.delete_insensitive(tags, "nsfw")
    } else {
      tags.add("nsfw")
    }

    const tag_names = Sets.to_array(tags);

    let res = await Posts.update_tags({post_id: id, tag_names})
    if(res.tag === "Success") {
      PubSub.publish(`post:${id}.updated_tags`, tags);
    }
  }

  update_tags(_topic, new_tags) {
    this.element.dataset.tags = Sets.join(new_tags, " ");

    let controllers = new Set(this.element.dataset.controller.split(" "))

    if(Sets.has_insensitive(new_tags, "nsfw")) {
      controllers.add("content-warning");
      this.element.setAttribute("nsfw", "true");
    } else {
      controllers.delete("content-warning")
      this.element.removeAttribute("nsfw");
    }

    this.element.dataset.controller = Sets.join(controllers, " ")
  }

  _join_post_channel() {
    Channel.subscribe(this.channel_topic, "deleted",
      () => this._replace_with_tombstone()
    ).then(ref => this.channel_refs.push(ref));

    Channel.subscribe(this.channel_topic, "tags_updated",
      ({new_tags}) => PubSub.publish(`post:${this.id}.updated_tags`, new Set(new_tags))
    ).then(ref => this.channel_refs.push(ref));
  }

  _leave_post_channel() {
    for(let ref of this.channel_refs) {
      Channel.unsubscribe(this.channel_topic, ref)
    }
  }

  _replace_with_tombstone() {
    this.element.outerHTML = `
      <div class="post-tombstone">
        ${gettext("This post is no longer available")}
      </div>
    `
  }
}
