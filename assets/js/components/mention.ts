import { html, render } from "uhtml";
import { define } from "wicked-elements";
import { Timer } from "~js/lib/utils/timer";
import { reactive, ref } from "./component";
import * as Fetch from "~js/lib/utils/fetch";

customElements.define("emb-mention", class extends HTMLElement {
  state = reactive({
    loaded: false,
    loading: false,
    error: false,
    user_data: null,
    open: false
  }, () => this.update())

  timer = null;

  connectedCallback() {
    this.addEventListener("mouseover", this.start_timer);
    this.addEventListener("mouseleave", this.hide_popup);
    this.update()
  }

  update() {
    render(this, html`
    <a href=${"/@" + this.dataset.name}>@${this.dataset.name}</a>
    <div ref="popup" class=${this.state.open ? "open" : ""}>
      ${this.state.loading
        ? `Loading user...`
        : this.state.loaded
          ? this.render_usercard(this.state.user_data)
          : ``
      }
      ${this.state.error
        ? html`
          <p>There was an error loading the user</p>
          <button class="button" onclick=${this.load_user}>Retry</button>
        `
        : ``
      }
    </div>
    `)
    this.position();
  }

  start_timer = () => {
    if(this.timer) this.stop_timer();
    this.timer = new Timer(500, this.show_popup);
  }
  stop_timer = () => {
    this.timer.pause();
  }

  show_popup = () => {
    this.state.open = true;
    if(!this.state.loaded) this.load_user();
  }
  hide_popup = () => {
    this.stop_timer();
    this.state.open = false;
  }

  load_user = async () => {
    this.state.loading = true;
    const res = await Fetch.get(`/@${this.dataset.name}`, {accept: "json"});
    switch(res.tag) {
      case "Success": {
        this.state.user_data = await res.value.json();
        this.state.loaded = true;
        break;
      }
      default: {
        break;
      }
    }
    this.state.loading = false;
  }

  render_usercard = (user) => {
    return html`
      <section class="user-resume">
        <a href=${`/@${user.username}`} class="username">
          <img class="avatar" src=${user.avatar.medium}>
          <span class="display-name">
            <bdi>${user.username}</bdi>
          </span>
        </a>
      </section>
      <p class="bio">
        ${user.bio}
      </p>
    `
  }

  position = () => {
    const { popup } = ref(this);
    const popup_rect = (<HTMLElement>popup).getBoundingClientRect();

    if(popup_rect.x + popup_rect.width > window.innerWidth) {
      popup.style.left = -(popup_rect.x + popup_rect.width - window.innerWidth + 30) + "px";
    } else {
      popup.style.left = "0px";
    }

    if(popup_rect.y < 0) {
      popup.style.top = `1.5em`
      popup.style.bottom = null
    } else {
      popup.style.bottom = `1.5em`
      popup.style.top = null
    }
  }

})
