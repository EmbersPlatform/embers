import { html, render } from "uhtml";
import { hydrate, ref } from "~js/components/component";
import { dgettext } from "~js/lib/gettext";
import type { Role } from "./mod-role";

customElements.define("mod-roles-index", class extends HTMLDivElement {
  roles: Role[] = [];

  connectedCallback() {
    setTimeout(() => {
      this.roles = hydrate(this);
      this.update();
    })
  }

  update = () => {
    const { list } = ref(this);
    render(list, html`
    <table>
      <thead>
        <th>${dgettext("mod-roles", "Name")}</th>
        <th>${dgettext("mod-roles", "Permissions")}</th>
        <th></th>
      </thead>
      <tbody>
        ${this.roles.map(render_role)}
      </tbody>
    </table>
    `)
  }
}, {extends: "div"})

const render_role = (role: Role) => html`<tr is="mod-role" .role=${{id: role.id, name: role.name, permissions: role.permissions}} />`
