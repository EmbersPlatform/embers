import { BaseController } from "~js/lib/controller";

import * as Timeline from "~js/lib/timeline";
import { gettext } from "~js/lib/gettext";
import LoadingIndicator from "~js/components/loading_indicator";

import PubSub from "pubsub-js";
import ActivitiesCache from "./activities_cache";

enum States {Idle, Loading, Finished};

export const name = "timeline";

export default class TimelineController extends BaseController {
  static targets = [
    "editor",
    "feed",
    "loadingIndicator",
    "newActivityAlert"
  ];

  state: States;
  next: string;
  last_page: boolean;

  unread_activities: ActivitiesCache;

  pubsub_feed_token: string;

  connect() {
    this.state = States.Idle;
    this.next = this.element.dataset.next;
    if(!this.next) {
      this.state = States.Finished;
      this.appendActivity(`
        <p>${gettext("You reached the bottom!")}</p>
      `)
    }

    this.unread_activities = new ActivitiesCache(this);

    this.pubsub_feed_token = PubSub.subscribe("new_activity", (_, post) => {
      this.unread_activities.add(post);
    })
  }

  disconnect() {
    PubSub.unsubscribe(this.pubsub_feed_token);
    this.unread_activities.flush();
  }

  addActivity(activity) {
    this.get_target("feed").insertAdjacentHTML("afterbegin", activity)
  }

  appendActivity(activity) {
    this.get_target("feed").insertAdjacentHTML("beforeend", activity)
  }

  onNewActivity({ detail: activity }) {
    this.addActivity(activity)
  }

  async loadMore() {
    if(this.state !== States.Idle) return;
    this.state = States.Loading;
    this.get_target<LoadingIndicator>("loadingIndicator").show();

    const response = await Timeline.get({ before: this.next })
    switch(response.tag) {
      case "Success": {
        let {next, last_page, body: activities} = response.value
        this.next = next;
        this.last_page = last_page;
        this.get_target("feed").insertAdjacentHTML("beforeend", activities);
        if(this.last_page) {
          this.appendActivity(`
            <p>${gettext("You reached the bottom!")}</p>
          `)
        }
        break;
      }
      case "Error": {
        console.error("Error retrieving timeline", response.value)
        break;
      }
      case "NetworkError": {
        console.error("Could not connect to server")
        break;
      }
    }

    this.state = (this.last_page) ? States.Finished : States.Idle;
    this.get_target<LoadingIndicator>("loadingIndicator").hide();
  }

  flush_activities() {
    let posts = this.unread_activities.flush();
    for(let post of posts) {
      this.get_target("feed").prepend(post)
    }
    window.scrollTo({top: 0, behavior: "smooth"});
  }

  _update_alert() {
    const count = this.unread_activities.length;

    if(count < 1) {
      this.get_target("newActivityAlert").textContent = "";
    } else {
      this
        .get_target("newActivityAlert")
        .textContent = gettext(`${count.toString()} new posts`);
    }
  }
}


