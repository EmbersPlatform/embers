// @ts-check

import {html} from "heresy";

import ModalDialog from "../dialog/dialog.comp";

import i18n from "~js/lib/gettext";

import * as Posts from "~js/lib/posts";

import back_icon from "/static/svg/generic/icons/angle-left.svg";

enum States {Initializing, Idle, Loading, Error, Finished, Empty};

export default class ReactionsDialog extends ModalDialog {
  static component = "ReactionsDialog";


  static mappedAttributes = [
    ...ModalDialog.mappedAttributes,
    "selected_reaction",
    "r_state",
    "list"
  ];

  r_state = States.Initializing;
  selected_reaction
  list: string
  last_page: boolean
  next: string
  overview: Posts.ReactionOverview[];

  oninit() {
    super.oninit();

    this.selected_reaction = "all";
    this.addEventListener("click", this.on_click.bind(this));

    this.r_state = States.Idle;
  }

  on_click(event) {
    const target = event.target.closest("button.reaction");
    if(!target) return;
    if(target.dataset.name == this.selected_reaction) return;
    this.r_state = States.Idle;
    this.selected_reaction = target.dataset.name;
  }

  onselected_reaction() {
    if(States.Initializing === this.r_state) return;
    this._fetch_reactions();
  }

  onr_state() {
    if(States.Initializing === this.r_state) return;
    this.render();
  }

  onlist() {
    this.render();
  }

  async _fetch_reactions(after?: string) {
    if(States.Loading === this.r_state) return;
    this.r_state = States.Loading;
    if(!after) this.list = "";

    const res = await Posts.get_reactions(this.dataset.postId, this.selected_reaction, after)
    switch(res.tag) {
      case "Success": {
        const page = res.value;
        this.list = (after) ? this.list + page.body : page.body;
          this.last_page = page.last_page;
          this.next = page.next;
          this.r_state =
            this.list == ""
              ? States.Empty
              : this.last_page
                ? States.Finished
                : States.Idle;
        break;
      }
      case "Error": {
        this.r_state = States.Error
        break;
      }
      case "NetworkError": {
        this.r_state = States.Error
        break;
      }
    }
  }

  async _fetch_overview() {
    const res = await Posts.get_reactions_overview(this.dataset.postId);
    switch(res.tag) {
      case "Success": {
        this.overview = res.value;
        this.render();
        break;
      }
      case "Error":
      case "NetworkError": {
        break;
      }
    }
  }

  showModal() {
    super.showModal();

    this._fetch_reactions();
    this._fetch_overview();
  }

  render() {
    const close = () => this.close();
    const load_more = () => {
      if(States.Finished === this.r_state) return;
      this._fetch_reactions(this.next);
    }

    const contents = html`
      <header>
        <button class="plain-button" onclick=${close}>${{html: back_icon}}</button>
        <span>${i18n.dgettext("reactions-dialog", "Reactions")}</span>
      </header>
      <section class="dialog-content">
        <div class="reactions-overview">
          <button
            class="reaction"
            data-name="all"
            selected=${this.selected_reaction == "all" || null}
          >
            ${i18n.dgettext("reactions-dialog", "All")}
          </button>
          ${(this.overview)
            ? this.overview.map(reaction =>
              html.for(this, reaction.name)`
                <button
                  class="reaction"
                  data-name=${reaction.name}
                  selected=${this.selected_reaction == reaction.name || null}
                >
                  <img src="/svg/reactions/${reaction.name}.svg"/>
                  <span class="reaction-total">${reaction.count}</span>
                </button>
              `)
            : ``
          }
          <button class="button" onclick=${close}>
            ${{html: back_icon}}
          </button>
        </div>
        <div class="reactions-list">
          ${{html: this.list}}
          ${get_status_text(this.r_state)}
          <intersect-observer onintersect=${load_more} />
        </div>
      </section>
    `
    this.html`${this.render_dialog(contents)}`
  }
}

function get_status_text(state: States) {
  switch(state) {
    case States.Initializing:
    case States.Idle:
    case States.Finished:
      return ``;
    case States.Loading:
      return html`
        <p>${i18n.dgettext("reactions-dialog", "Fetching reactions...")}</p>
      `;
    case States.Error:
      return html`
        <p>${i18n.dgettext("reactions-dialog", "There was an error loading reactions.")}</p>
      `;
    case States.Empty:
      return html`
        <p>${i18n.dgettext("reactions-dialog", "This post has no reactions :(")}</p>
      `;
  }
}
