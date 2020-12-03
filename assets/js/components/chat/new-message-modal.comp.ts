import { html, ref } from "heresy";
import ModalDialog from "../dialog/dialog.comp";
import Pjax from "pjax-api";
import * as Fetch from "~js/lib/utils/fetch";
import throttle from "~js/lib/utils/throttle";
import { UserData } from "~js/lib/application";
import { dgettext } from "~js/lib/gettext";

export default class NewMessageModal extends ModalDialog {
  static component = "NewMessageModal";

  abort_controller: AbortController;

  results = [];

  current = 0;

  handle_keyup = (event: KeyboardEvent) => {
    if(event.key === "Enter") {
      this.select_user();
      return;
    }

    if(event.key == "ArrowDown") {
      if(this.current < this.results.length - 1) {
        this.current++;
      } else {
        this.current = 0;
      }
      this.render();
      return;
    }

    if(event.key == "ArrowUp") {
      if(this.current > 0) {
        this.current--;
      } else {
        this.current = this.results.length - 1;
      }
      this.render();
      return;
    }

    this.current = 0;
    const term = (event.target as HTMLInputElement).value;
    this.fetch_users(term);
  }

  fetch_users = throttle(async (term) => {
    if(this.abort_controller)
      this.abort_controller.abort();
    this.abort_controller = new AbortController();

    const res = await Fetch.get(`/search_typeahead/user/${term}`, {signal: this.abort_controller.signal});
    if(res.tag === "Success") {
      this.results = await res.value.json();
      this.render();
    }
  }, 500)

  select_user = () => {
    if(!this.results) return;
    const username = this.results[this.current].username;
    Pjax.assign(`/chat/@${username}`, {});
  }

  render() {

    const template = html`
      <header>
        <input placeholder="${dgettext("chat", "Who do you want to talk to?")}" onkeyup=${this.handle_keyup}/>
      </header>
      <section class="results">
        ${this.results.map(render_user(this))}
      </section>
    `

    this.html`
      ${this.render_dialog(template)}
    `
  }
}

const render_user = (host: NewMessageModal) => (user: UserData, index: number) => html`
<a href=${`/chat/@${user.username}`} class="user-typeahead-result ${host.current == index ? `active` : ``}">
  <figure class="avatar">
    <img src=${user.avatar.small} />
  </figure>
  <span class="username">${user.username}</span>
<a>
`
