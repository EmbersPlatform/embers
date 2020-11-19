import { Component } from "../component";
import * as Application from "~js/lib/application";
import * as Notifications from "~js/lib/notifications";
import IntersectObserver from "../intersection_observer/intersection_observer.comp";
import LoadingIndicator from "../loading_indicator/loading_indicator.comp";
import * as Channel from "~js/lib/socket/channel";

const user = Application.get_user();

enum State {
  Idle,
  Loading,
  Finished,
}

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

  pubsub_subs = [];

  onconnected() {
    this.next = this.dataset.next;
    this.last_page = this.dataset.last_page == "true";
    this.notifs_section = this.querySelector("section");
    this.iobserver = this.querySelector("intersect-observer");
    this.loading_indicator = this.querySelector("loading-indicator");

    this.on_click = this.on_click.bind(this);
    this._fetch_more = this._fetch_more.bind(this);

    document.addEventListener("click", this.on_click);
    this.iobserver.addEventListener("intersect", this._fetch_more);

    Channel.subscribe(`user:${user.id}`, "notification", (notification) => {
      if (notification.ephemeral) return;
      const node = document.createElement("e-notification");
      for (let prop in notification) {
        node.dataset[prop] = notification[prop];
      }
      node.dataset.status = ["unseen", "seen", "read"][notification.status];
      this.notifs_section.prepend(node);
    }).then((token) => this.pubsub_subs.push(token));

    Channel.subscribe(
      `user:${user.id}`,
      "notification_read",
      (notification) => {
        for (let node of this.notifs_section.children as any) {
          if (node.dataset.id != notification.id) continue;
          node.dataset.status = "read";
        }
      }
    ).then((token) => this.pubsub_subs.push(token));
  }

  ondisconnected() {
    document.removeEventListener("click", this.on_click);
    this.iobserver.removeEventListener("intersect", this._fetch_more);
    this.pubsub_subs.forEach((token, i) => {
      Channel.unsubscribe(token).then(() => {
        delete this.pubsub_subs[i];
      });
    });
  }

  on_click(event: MouseEvent) {
    const target = event.target as HTMLElement;
    const trigger = target.closest(
      "[notifications-panel-trigger]"
    ) as HTMLElement;

    if (trigger) {
      if (this.open) {
        this.hide();
        return;
      }
      this.show(trigger);
      return;
    }

    if (!this.contains(target)) {
      this.hide();
      return;
    }
  }

  show(trigger?: HTMLElement) {
    if (trigger) {
      this.current_trigger = trigger;
      this.current_trigger.classList.add("active");
    }
    this.open = true;
    this.focus();
    Notifications.get({ mark_as_seen: true });
  }

  hide() {
    this.open = false;
    if (this.current_trigger) {
      this.current_trigger.classList.remove("active");
      this.current_trigger = undefined;
    }
    for (let notification of this.notifs_section.children as any) {
      if (notification.dataset.status == "unseen")
        notification.dataset.status = "seen";
    }
  }

  async _fetch_more() {
    if (this.state !== State.Idle) return;
    if (this.last_page) return;
    this.state = State.Loading;
    this.loading_indicator.show();
    const res = await Notifications.get({ before: this.next });
    switch (res.tag) {
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
    this.state = this.last_page ? State.Finished : State.Idle;
  }
}
