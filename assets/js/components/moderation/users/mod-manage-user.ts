import { define, html, ref } from "heresy"
import ModalDialog from "~js/components/dialog/dialog.comp";
import { dgettext, gettext } from "~js/lib/gettext";
import type { Mod_UserData } from "./user-summary";
import * as Fetch from "~js/lib/utils/fetch";
import status_toasts from "~js/managers/status_toasts";

define("ModManageUser", class extends ModalDialog {
  static mappedAttributes = ["user"];

  user: Mod_UserData;

  username_input = ref<HTMLInputElement>();
  email_input = ref<HTMLInputElement>();
  bio_textarea = ref<HTMLTextAreaElement>();
  roles_select = ref<HTMLSelectElement>();

  existing_roles;

  update = async () => {

    let new_roles = [];
    for(let opt of this.roles_select.current.selectedOptions) {
      new_roles.push(opt.value);
    }

    const new_user = {
      username: this.username_input.current.value,
      email: this.email_input.current.value,
      bio: this.bio_textarea.current.value,
      roles: new_roles
    }

    const res = await Fetch.put(`/moderation/users/${this.user.id}`, new_user, {type: "json"})

    switch(res.tag) {
      case "Success": {
        const user = await res.value.json();
        this.user = user;
        this.dispatch("update", this.user);
        status_toasts.add({content: dgettext("mod-user", "User updated successfully"), classes: ["success"]})
        this.close();
        break;
      }
      default: {
        status_toasts.add({content: dgettext("mod-user", "There was an error"), classes: ["danger"]})
      }
    }

  }

  remove_avatar = async () => {
    const res = await Fetch.delet(`/moderation/users/${this.user.id}/avatar`);

    switch(res.tag) {
      case "Success": {
        const avatar = await res.value.json();
        if(avatar) {
          this.user.avatar = avatar;
        }
        this.dispatch("update", this.user);
        break;
      }
    }
    this.render();
  }


  remove_cover = async () => {
    const res = await Fetch.delet(`/moderation/users/${this.user.id}/cover`);

    switch(res.tag) {
      case "Success": {
        const cover = await res.value.text();
        if(cover) {
          this.user.cover = cover;
        }
        this.dispatch("update", this.user);
        break;
      }
    }
    this.render();
  }

  render() {
    const contents = html`
      <header><span class="dialog-title">${dgettext("mod-user", "Manage %1", this.user.username)}</span></header>
      <div class="cover-header" style="background-image: url(${this.user.cover});">
        <img class="cover-avatar" src=${this.user.avatar.big} />
      </div>
      <section>
        <div class="details">
          <label>
            <strong>${gettext("Username")}</strong>
            <input type="text" ref=${this.username_input} placeholder=${gettext("Username")} value=${this.user.username} />
          </label>
          <label>
            <strong>${gettext("Email")}</strong>
            <input type="email" ref=${this.email_input} placeholder=${gettext("Email")} value=${this.user.email} />
          </label>
          <label>
            <strong>${gettext("Bio")}</strong>
            <textarea is="autosize-textarea" ref=${this.bio_textarea} placeholder=${gettext("Bio")}>${this.user.bio}</textarea>
          </label>
        </div>
        <div class="other">

          <div class="group">
            <button class="button" onclick=${this.remove_avatar}>${dgettext("mod-user", "Remove avatar")}</button>
            <button class="button" onclick=${this.remove_cover}>${dgettext("mod-user", "Remove cover")}</button>
          </div>

          <label>
            <strong>${dgettext("mod-user", "Roles")}</strong>
            <select multiple ref=${this.roles_select}>
              ${this.render_roles_options()}
            </select>
          </label>
        </div>
      </section>
      <footer>
        <button class="button" onclick=${() => this.close()}>${gettext("Cancel")}</button>
        <button class="button primary" onclick=${this.update}>${gettext("Save changes")}</button>
      </footer>
    `

    this.html`${this.render_dialog(contents)}`
  }

  render_roles_options = () => {
    const has_role = role => {
      for(let r of this.user.roles) {
        if(r.id === role.id) return true;
      }
      return false;
    }

    return html`${this.existing_roles.map(role => html`
      <option value=${role.id} .selected=${has_role(role)}>${role.name}</option>
    `)}`
  }
})
