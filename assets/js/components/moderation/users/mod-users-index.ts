import { render, html } from "uhtml";
import throttle from "~js/lib/utils/throttle";
import * as Fetch from "~js/lib/utils/fetch";
import { reactive } from "~js/components/component";
import { gettext } from "~js/lib/gettext";

customElements.define("mod-users-index", class extends HTMLElement {

  /**
   * Reactive state.
   */
  state = reactive({
    loading: false,
    error: false,
    page: {
      entries: [],
      next: null,
      last_page: false
    }
  }, () => this.update());

  filters = {
    canonical: "",
    email: ""
  }

  existing_roles = [];

  abort_controller: AbortController;

  connectedCallback() {
    setTimeout(() => {
      this.existing_roles = JSON.parse(this.querySelector("script[type=data]").textContent)
      this.update();
      this.fetch_users();
    })
  }

  /**
   * Filters users by field and throttles calls by 500 ms
   */
  filter = field => throttle(({target}) => {
    this.filters[field] = target.value

    this.fetch_users();
  }, 500);

  /**
   * Fetches the users.
   * @param next If true, appends results to the page. It also makes the function
   * a no-op if it's the last page.
   */
  fetch_users = async (next = false) => {
    if(this.state.loading) return;
    if(next && this.state.page.last_page) return;

    this.abort_previous_request();

    this.state.loading = true;
    this.state.error = false;

    if(!next) {
      this.state.page.next = null;
      this.state.page.last_page = true;
    }


    const params = {
      canonical: this.filters.canonical,
      email: this.filters.email,
      before: null
    }

    if(next)
      params.before = this.state.page.next;

    const res = await Fetch.get(`/moderation/users/list.json`, {params, signal: this.abort_controller.signal});
    if(res.tag !== "Success") {
      this.state.error = true;
      this.state.loading = false;
      return;
    }

    const page = await res.value.json()

    if(next) {
      this.state.page.entries = [...this.state.page.entries, ...page.entries];
    } else {
      this.state.page.entries = page.entries;
    }

    this.state.page.next = page.next;
    this.state.page.last_page = page.last_page;

    this.state.loading = false;
  }

  update() {
    render(this, html`
      <h1>${gettext("Users")}</h1>

      <div class="filters boxed">
        <h3>${gettext("Filter")}</h3>
        <div class="filters-inputs">
          <input type="text" placeholder=${gettext("Username")} onkeyup=${this.filter("canonical")} >
          <input type="text" placeholder=${gettext("Email")} onkeyup=${this.filter("email")} >
        </div>
      </div>

      <section class="boxed">
        ${(this.state.page.entries.length <= 0 && !this.state.loading)
          ? html`<p class="no-results">${gettext("No results")}</p>`
          : ``
        }
        ${this.state.page.entries.map(user => html.for(user, user.id)`
          <user-summary
            .user=${user}
            .highlight_username=${this.filters.canonical}
            .highlight_email=${this.filters.email}
            .existing_roles=${this.existing_roles}
          />
        `)}
      </section>
      <intersect-observer onintersect=${() => this.fetch_users(true)} />
      <p class="loading-indicator">${this.state.loading
        ? gettext("Loading...")
        : this.state.error
          ? html`
            <span class="text-error">${gettext("An error ocurred")} </span>
            <button class="button primary" onclick=${() => this.fetch_users(true)}>${gettext("Retry")}</button>
            `
          : ``
      }</p>
    `);
  }

  abort_previous_request = () => {
    if(this.abort_controller)
      this.abort_controller.abort();
    this.abort_controller = new AbortController();
  }

}, {extends: "main"})
