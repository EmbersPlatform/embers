import { html, render } from "uhtml";
import { reactive } from "~js/components/component";
import { dgettext, gettext } from "~js/lib/gettext";
import * as Fetch from "~js/lib/utils/fetch";
import status_toasts from "~js/managers/status_toasts";

const existing_permissions = {
  "any": dgettext("mod-roles", "Any"),
  "create_post": dgettext("mod-roles", "Create posts"),
  "update_post": dgettext("mod-roles", "Edit posts"),
  "delete_post": dgettext("mod-roles", "Delete posts"),
  "create_media": dgettext("mod-roles", "Create media"),
  "update_media": dgettext("mod-rules", "Update medias"),
  "delete_media": dgettext("mod-rules", "Delete medias"),
  "access_backoffice": dgettext("mod-rules", "Access admin panel"),
  "access_mod_tools": dgettext("mod-rules", "Access moderation tools"),
  "access_reports_queue": dgettext("mod-rules", "Access reports queue"),
  "create_report": dgettext("mod-rules", "Create report"),
  "manage_reports": dgettext("mod-rules", "Manage reports"),
  "request_ban": dgettext("mod-rules", "Request ban"),
  "request_warn": dgettext("mod-rules", "Request warn"),
  "ban_user": dgettext("mod-rules", "Ban user"),
  "warn_user": dgettext("mod-rules", "Warn user")
}

export type Role = {
  id: string,
  name: string,
  permissions: string[]
}

customElements.define("mod-role", class extends HTMLTableRowElement {
  role: Role;

  state = reactive({
    editing: false,
    updating: false
  }, () => this.update());

  edit_data = reactive({
    name: "",
    permissions: []
  }, () => this.update());

  connectedCallback() {
    this.edit_data.permissions = this.role.permissions;
    this.edit_data.name = this.role.name;
  }

  update = () => {
    render(this, this.state.editing ? this.render_editor() : this.render_row())
  }

  render_row = () => html`
    <td class="role-name">${this.role.name}</td>
    <td class="permissions-list">
      ${this.role.permissions.map(x => html`<span class="permission">${x}</span>`)}
    </td>
    <td class="actions">
      <button class="button" onclick=${() => this.state.editing = true}>${gettext("Edit")}</button>
    </td>
  `

  toggle_perm = perm => {
    if(this.edit_data.permissions.includes(perm)) {
      this.edit_data.permissions = this.edit_data.permissions.filter(x => x !== perm);
    } else {
      this.edit_data.permissions = [...this.edit_data.permissions, perm];
    }
    this.update();
  }

  save_changes = async () => {
    if(this.state.updating) return;
    this.state.updating = true;

    const res = await Fetch.put(`/moderation/roles/${this.role.id}`, {
      name: this.edit_data.name,
      permissions: this.edit_data.permissions
    }, {type: "json"});
    switch(res.tag) {
      case "Success": {
        status_toasts.add({content: gettext("Role updated!"), classes: ["success"]});
        this.state.editing = false;
        break;
      }
    }

    this.state.updating = false;
  }

  update_name = ({target}) => {
    this.edit_data.name = target.value;
  }

  render_editor = () => html`
    <td colspan="3" class="role-editor">
      <div class="role-editor-details">
        <label>
          ${gettext("Name")}
          <input type="text" value=${this.role.name} onchange=${this.update_name} placeholder=${gettext("Name")}/>
        </label>

        ${gettext("Permissions")}
        <div class="permissions">
          ${Object.keys(existing_permissions).map(perm => html`
            <label>
              <input
                type="checkbox"
                value=${perm}
                onchange=${() => this.toggle_perm(perm)}
                .checked=${this.edit_data.permissions.includes(perm)}
                .disabled=${perm !== "any" && this.edit_data.permissions.includes("any")}
              >${existing_permissions[perm]}
            </label>
          `)}
        </div>
      </div>
      <div class="actions">
      <button class="button" onclick=${() => this.state.editing = false}>${gettext("Cancel")}</button>
        <button class="button" onclick=${this.save_changes}>${gettext("Save changes")}</button>
      </div>
    </td>
  `
}, {extends: "tr"})
