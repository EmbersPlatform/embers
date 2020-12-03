import { render, html } from "uhtml";
import type ModalDialog from "~js/components/dialog/dialog.comp";
import { gettext, dgettext } from "~js/lib/gettext";
import icon_external from "~static/svg/generic/icons/external-link.svg";

const textNode = document.createTextNode.bind(document);

const ref = (elem, name) => {
  return elem.querySelector(`[ref=${name}]`);
}

type Avatar = {
  small: string,
  medium: string,
  big: string
}

type Role = {
  id: string,
  name: string
}

export interface Mod_UserData {
  id: string,
  username: string,
  canonical: string,
  email: string,
  bio: string,
  avatar: Avatar,
  cover: string,
  roles?: Role[]
}

customElements.define("user-summary", class extends HTMLElement {
  user: Mod_UserData;

  highlight_username: string;
  highlight_email: string;

  existing_roles = [];

  connectedCallback() {
    this.update();
  }

  update = () => {
    render(this, html`
      <div class="user-data">
        <img class="avatar" src=${this.user.avatar.small} />
        <div class="user-details">
          <strong>${highlight(this.highlight_username, this.user.username)}</strong>
          <span>${highlight(this.highlight_email, this.user.email)}</span>
        </div>
      </div>
      <div class="roles">
        ${this.user.roles.map(role => html`
          <div class="role">${role.name}</div>
        `)}
      </div>
      <div class="actions">
        <a href=${`/@${this.user.canonical}`} target="_blank">${dgettext("mod-user", "View profile")} ${{html: icon_external}}</a>
        <button class="button" onclick=${this.manage}>${dgettext("mod-user", "Manage user")}</button>
      </div>
      <mod-manage-user .existing_roles=${this.existing_roles} ref="manage-dialog" .user=${this.user} onupdate=${this.update_data}/>
    `)
  }

  manage = () => {
    ref(this, "manage-dialog").showModal();
  }

  update_data = event => {
    this.user = event.detail;
    this.update();
  }
})

const highlight = (match, text) => {
  if(!match || match.length <= 0) return text;

  return text.split(new RegExp(match, "i")).flatMap(x => [html`<mark>${match}</mark>`, textNode(x)]).slice(1)
}
