import { BaseController } from "~js/lib/controller";
import {html, render} from "heresy";

import { add_reaction, remove_reaction } from "~js/lib/posts";
import * as Channel from "~js/lib/socket/channel";

export const name = "reactable"

export default class extends BaseController {
  static targets = ["reactions"]

  channel_ref: number

  connect() {
    super.connect();
    if(this._in_preview) return;
    Channel.subscribe(`post:${this.element.dataset.id}`, "reactions_updated",
      ({added, removed}) => {
        if(added)
          this._add_reactions(added);
        if(removed)
          this._remove_reactions(removed);
      }
    )
    .then(ref => this.channel_ref = ref);
  }

  disconnect() {
    if(this._in_preview) return;
    Channel.unsubscribe(`post:${this.element.dataset.id}`, this.channel_ref);
  }

  set_reactions(html) {
    this.get_target("reactions").innerHTML = html;
  }

  async add_reaction(reaction) {
    const res = await add_reaction(this.element.dataset.id, reaction);
    switch(res.tag) {
      case "Success": {
        this.set_reactions(res.value);
        break;
      }
      case "Error": {
        // console.log(res.value);
        break;
      }
      case "NetworkError": {
        console.error("Error contacting server");
        break;
      }
    }
  }

  async remove_reaction(reaction) {
    const res = await remove_reaction(this.element.dataset.id, reaction)
    switch(res.tag) {
      case "Success": {
        this.set_reactions(res.value);
        break;
      }
      case "Error": {
        // console.log(res.value);
        break;
      }
      case "NetworkError": {
        console.error("Error contacting server");
        break;
      }
    }
  }

  has_reaction(reaction) {
    const reactions = Array.from(this.get_target("reactions").children) as HTMLElement[];
    return !!reactions.find(x => x.dataset.name == reaction && x.hasAttribute("reacted"))
  }


  onToggleReaction(event) {
    let target = event.currentTarget;
    target.disabled = true
    if (target.hasAttribute("reacted"))
    this.remove_reaction(target.dataset.name)
    else
    this.add_reaction(target.dataset.name)
  }

  onAddReaction(event) {
    if (this.has_reaction(event.detail)) return;
    this.add_reaction(event.detail)
  }

  _add_reactions(names) {
    for(let name of names) {
      let reaction = this._get_reaction_node(name);
      if(!reaction) {
        reaction = this._build_reaction(name);
        this.get_target("reactions").appendChild(reaction);
      } else {
        let new_total = parseInt(reaction.dataset.total) + 1;
        reaction.dataset.total = new_total.toString();
        reaction.querySelector(".reaction-total").textContent = new_total.toString();
      }
    }
  }

  _remove_reactions(names) {
    for(let name of names) {
      let reaction = this._get_reaction_node(name);
      if(!reaction) return;

      let new_total = parseInt(reaction.dataset.total) - 1;
      if(new_total <= 0) {
        reaction.remove();
      } else {
        reaction.dataset.total = new_total.toString();
        reaction.querySelector(".reaction-total").textContent = new_total.toString();
      }
    }
  }

  _get_reaction_node(reaction) {
    const reactions = Array.from(this.get_target("reactions").children) as HTMLElement[];
    return reactions.find((x) => x.dataset.name == reaction)
  }

  _build_reaction(name) {
    const reaction_image = `/svg/reactions/${name}.svg`;
    const hole = html`
      <button
        class="reaction"
        data-name=${name}
        data-total="1"
        data-action="click->reactable#onToggleReaction"
      >
        <img src=${reaction_image}>
        <span class="reaction-total">1</span>
      </button>
    `;
    const holder = document.createElement("div");
    render(holder, hole);
    return holder.firstElementChild as HTMLElement;
  }
}
