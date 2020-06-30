import { Component } from "../component";
import * as Notifications from "~js/lib/notifications";
import IntersectObserver from "../intersection_observer";
import LoadingIndicator from "../loading_indicator";

enum State {Idle, Loading, Finished}

export default class NotificationsPanel extends Component(HTMLElement) {
  static component = "NotificationsPanel";

  static tagName = "nav";

  static booleanAttributes = ["open"];

  open: boolean;

  current_trigger: HTMLElement;
  notifs_section: HTMLElement;

  next: string;
  last_page: boolean;

  iobserver: IntersectObserver;
  loading_indicator: LoadingIndicator;

  state = State.Idle;

  onconnected() {
    this.next = this.dataset.next;
    this.last_page = !!this.dataset.last_page;
    this.notifs_section = this.querySelector("section");
    this.iobserver = this.querySelector("intersect-observer");
    this.loading_indicator = this.querySelector("loading-indicator");

    this.on_click = this.on_click.bind(this);
    this._fetch_more = this._fetch_more.bind(this);

    document.addEventListener("click", this.on_click);
    this.iobserver.addEventListener("intersect", this._fetch_more);
  }

  ondisconnected() {
    document.removeEventListener("click", this.on_click);
    this.iobserver.removeEventListener("intersect", this._fetch_more);
  }

  on_click(event: MouseEvent) {
    const target = event.target as HTMLElement;
    const trigger = target.closest("[notifications-panel-trigger]") as HTMLElement;

    if(trigger) {
      if(this.open) {
        this.hide();
        return;
      }
      this.show(trigger);
      return;
    }

    if(!this.contains(target)) {
      this.hide();
      return;
    }
  }

  show(trigger?: HTMLElement) {
    if(trigger) {
      this.current_trigger = trigger;
      this.current_trigger.classList.add("active");
    }
    this.open = true;
    this.focus();
  }

  hide() {
    this.open = false;
    if(this.current_trigger) {
      this.current_trigger.classList.remove("active");
      this.current_trigger = undefined;
    }
  }

  async _fetch_more() {
    if(this.state !== State.Idle) return;
    this.state = State.Loading;
    this.loading_indicator.show();
    const res = await Notifications.get({before: this.next});
    switch(res.tag) {
      case "Success": {
        this.notifs_section.insertAdjacentHTML("beforeend", res.value.body);
        this.next = res.value.next;
        this.last_page = res.value.last_page;
        break;
      }
      case "Error": {
        break;
      }
      case "NetworkError": {
        break;
      }
    }

    this.loading_indicator.hide();
    this.state = (this.last_page) ? State.Finished : State.Idle;
  }
}
