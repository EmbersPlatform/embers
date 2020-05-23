import {html} from "heresy";

import ModalDialog from "../dialog";

import union from "/js/lib/utils/union";
import i18n from "/js/lib/gettext";

import * as Posts from "/js/lib/posts";

import back_icon from "/static/svg/generic/icons/angle-left.svg";

const RStates = union("RStates", {
  Initializing: [],
  Idle: [],
  Loading: [],
  Error: [],
  Finished: [],
  Empty: []
});

export default {
  ...ModalDialog,
  name: "ReactionsDialog",

  mappedAttributes: ["selected_reaction", "r_state", "list"],

  oninit() {
    ModalDialog.oninit.apply(this);
    this.r_state = RStates.Initializing;

    this.selected_reaction = "all";
    this.addEventListener("click", this);

    this.r_state = RStates.Idle;
  },

  onclick(event) {
    const target = event.target.closest("button.reaction");
    if(!target) return;
    if(target.dataset.name == this.selected_reaction) return;
    this.r_state = RStates.Idle;
    this.selected_reaction = target.dataset.name;
  },

  onselected_reaction() {
    if(RStates.Initializing.is(this.r_state)) return;
    this._fetch_reactions();
  },

  onr_state() {
    if(RStates.Initializing.is(this.r_state)) return;
    this.render();
  },

  onlist() {
    this.render();
  },

  _fetch_reactions(after) {
    if(RStates.Loading.is((this.r_state))) return;
    this.r_state = RStates.Loading;
    if(!after) this.list = "";

    Posts.get_reactions(this.dataset.postId, this.selected_reaction, after)
    .then(res => {
      res.match({
        Success: page => {
          this.list = (after) ? this.list + page.body : page.body;
          this.last_page = page.last_page;
          this.next = page.next;
          this.r_state =
            this.list == ""
              ? RStates.Empty
              : this.last_page
                ? RStates.Finished
                : RStates.Idle;
        },
        Error: () => this.r_state = RStates.Error,
        NetworkError: () => this.r_state = RStates.Error
      })
    })
  },

  _fetch_overview() {
    Posts.get_reactions_overview(this.dataset.postId)
    .then(res => {
      res.match({
        Success: overview => {
          this.overview = overview;
          this.render();
        },
        Error: () => {},
        NetworkError: () => {}
      })
    })
  },

  showModal() {
    ModalDialog.showModal.apply(this);

    this._fetch_reactions();
    this._fetch_overview();
  },

  render() {
    const close = () => this.close();
    const load_more = () => {
      if(RStates.Finished.is((this.r_state))) return;
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
          ${this.r_state.match({
            Initializing: () => ``,
            Idle: () => ``,
            Loading: () => html`
              <p>${i18n.dgettext("reactions-dialog", "Fetching reactions...")}</p>
            `,
            Error: () => html`
              <p>${i18n.dgettext("reactions-dialog", "There was an error loading reactions.")}</p>
            `,
            Finished: () => ``,
            Empty: () => html`
              <p>${i18n.dgettext("reactions-dialog", "This post has no reactions :(")}</p>
            `
          })}
          <intersection-observer onintersect=${load_more} />
        </div>
      </section>
    `
    this.html`${this.render_dialog(contents)}`
  }
}
