import { Controller } from "stimulus";

import { add_reaction, remove_reaction } from "#/lib/posts";

export const name = "reactable"

export default class extends Controller {
  static targets = ["reactions"]

  set_reactions(html) {
    this.reactionsTarget.innerHTML = html;
  }

  add_reaction(reaction) {
    add_reaction(this.element.dataset.id, reaction)
    .then(res => {
      res.match({
        Success: html => this.set_reactions(html),
        Error: error => console.log(error),
        NetworkError: () => console.error("Error contacting server")
      })
    })
  }

  remove_reaction(reaction) {
    remove_reaction(this.element.dataset.id, reaction)
    .then(res => {
      res.match({
        Success: html => this.set_reactions(html),
        Error: error => console.log(error),
        NetworkError: () => console.error("Error contacting server")
      })
    })
  }

  has_reaction(reaction) {
    const reactionss = Array.from(this.reactionsTarget.children);
    return !!reactionss.find(x => x.dataset.name == reaction && x.hasAttribute("reacted"))
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
}
