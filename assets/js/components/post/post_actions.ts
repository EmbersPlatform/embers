import { html } from "heresy";
import { Component } from "../component";
import { gettext } from "~js/lib/gettext";

import * as Application from "~js/lib/application";

import icon_gavel from "~static/svg/generic/icons/gavel.svg";
import icon_ellipsis from "~static/svg/generic/icons/ellipsis-v.svg"

export default class PostActions extends Component(HTMLElement) {
  post: HTMLElement;
  faved: boolean;
  is_owner: boolean;

  onconnected() {
    this.post = this.closest(".post") as HTMLElement;
    this.is_owner = this.post.dataset["authorId"] === Application.get_user().id;
    this.faved = this.post.hasAttribute("faved");
    console.log(this.faved)
  }

  render() {
    if(!Application.is_authenticated()) {
      this.html``;
      return;
    }

    const mod_tools = Application.can("access_mod_tools")
      ? html`
      <div class="hover-menu-wrapper">
        <button class="plain-button">
          ${{html: icon_gavel}}
        </button>
          <div class="hover-menu bottom-right">
            <ol>
              <li>
                <button class="plain-button" data-action="click->post#toggle_nsfw">
                  <span class="is-nsfw">${gettext("Is NSFW")}</span>
                  <span class="isnt-nsfw">${gettext("Isn't NSFW")}</span>
                </button>
              </li>
              <li>
                <button class="plain-button danger">
                  <span>
                    ${gettext("Disable")}
                  </span>
                </button>
              </li>
              <li>
                <button class="plain-button danger">
                  <span>
                    ${gettext("Ban user")}
                  </span>
                </button>
              </li>
            </ol>
          </div>
      </div>
      `
      : ``;


    this.html`
    <div class="post-actions">
      ${mod_tools}
      <button
        is="post-fav-button"
        class="plain-button"
        data-post_id=${this.post.dataset.id}
      ></button>
      <div class="hover-menu-wrapper">
        <button class="plain-button">
          ${{html: icon_ellipsis}}
        </button>
        <div class="hover-menu bottom-right">
          <ol>
            <li>
              <button class="plain-button" data-action="click->post#show_reactions_modal">
                <span>${gettext("Reactions")}</span>
              </button>
            </li>
            <li>
              <button class="plain-button">
                <span>${gettext("Report")}</span>
              </button>
            </li>
            ${this.is_owner
              ? html`<li>
                <button class="plain-button danger" data-action="click->post#confirm_delete">
                  <span>${gettext("Delete")}</span>
                </button>
              </li>
              `
              : ``
            }
          </ol>
        </div>
      </div>
    </div>
    `
  }
}

/*

<%= if authenticated?(@conn) do %>
<div class="post-actions">
  <%= if Embers.Authorization.can?(@conn.assigns.current_user, "access_mod_tools") do %>
    <div class="hover-menu-wrapper">
      <button class="plain-button">
        <%= svg_image "icons/gavel" %>
      </button>
        <div class="hover-menu bottom-right">
          <ol>
            <li>
              <button class="plain-button" data-action="click->post#toggle_nsfw">
                <span class="is-nsfw"><%= gettext("Is NSFW") %></span>
                <span class="isnt-nsfw"><%= gettext("Isn't NSFW") %></span>
              </button>
            </li>
            <li>
              <button class="plain-button danger">
                <span>
                  <%= gettext("Disable") %>
                </span>
              </button>
            </li>
            <li>
              <button class="plain-button danger">
                <span>
                  <%= gettext("Ban user") %>
                </span>
              </button>
            </li>
          </ol>
        </div>
    </div>
  <% end %>
  <button
    is="post-fav-button"
    class="plain-button"
    data-post_id="<%= encode_id(@post.id) %>"
    <%= if @post.faved, do: "faved" %>
  ></button>
  <div class="hover-menu-wrapper">
    <button class="plain-button">
      <%= svg_image "icons/ellipsis-v" %>
    </button>
    <div class="hover-menu bottom-right">
      <ol>
        <li>
          <button class="plain-button" data-action="click->post#show_reactions_modal">
            <span><%= gettext("Reactions") %></span>
          </button>
        </li>
        <li>
          <button class="plain-button">
            <span><%= gettext("Report") %></span>
          </button>
        </li>
        <%= if is_owner?(@conn, @post) do %>
          <li>
            <button class="plain-button danger" data-action="click->post#confirm_delete">
              <span><%= gettext("Delete") %></span>
            </button>
          </li>
        <% end %>
      </ol>
    </div>
  </div>
</div>
<% end %>


*/
