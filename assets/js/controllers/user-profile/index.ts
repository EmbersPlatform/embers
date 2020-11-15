import { BaseController } from "~js/lib/controller";

import * as Users from "~js/lib/users";
import { gettext } from "~js/lib/gettext";
import LoadingIndicator from "~js/components/loading_indicator/loading_indicator.comp";

enum States {
  Idle,
  Loading,
  Finished,
}

export const name = "user-profile";

export default class UserProfile extends BaseController {
  static targets = ["feed", "loadingIndicator"];

  user: string;

  state: States;
  next: string;
  last_page: boolean;

  connect() {
    this.user = this.element.dataset.user;
    this.state = States.Idle;
    this.next = this.element.dataset.next;
    if (!this.next) {
      this.state = States.Finished;
      this.appendActivity(`
        <p class="reached-bottom-notice">${gettext(
          "You reached the bottom!"
        )}</p>
      `);
    }
  }

  addActivity(activity) {
    this.get_target("feed").insertAdjacentHTML("afterbegin", activity);
  }

  appendActivity(activity) {
    this.get_target("feed").insertAdjacentHTML("beforeend", activity);
  }

  async loadMore() {
    if (this.state !== States.Idle) return;
    this.state = States.Loading;
    this.get_target<LoadingIndicator>("loadingIndicator").show();

    const response = await Users.get_timeline(this.user, { before: this.next });
    switch (response.tag) {
      case "Success": {
        let { next, last_page, body: activities } = response.value;
        this.next = next;
        this.last_page = last_page;
        this.get_target("feed").insertAdjacentHTML("beforeend", activities);
        if (this.last_page) {
          this.appendActivity(`
            <p class="reached-bottom-notice">${gettext(
              "You reached the bottom!"
            )}</p>
          `);
        }
        break;
      }
      case "Error": {
        console.error("Error retrieving timeline", response.value);
        break;
      }
      case "NetworkError": {
        console.error("Could not connect to server");
        break;
      }
    }

    this.state = this.last_page ? States.Finished : States.Idle;
    this.get_target<LoadingIndicator>("loadingIndicator").hide();
  }
}
