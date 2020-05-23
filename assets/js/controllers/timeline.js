import { Controller } from "stimulus"
import union from "/js/lib/utils/union";

import * as Timeline from "/js/lib/timeline";
import i18n from "/js/lib/gettext"

const States = union("States", {
  Idle: [],
  Loading: [],
  Finished: []
})

export const name = "timeline"

export default class extends Controller {
  static targets = ["editor", "feed", "loadingIndicator"]

  connect() {
    this.state = States.Idle;
    this.next = this.element.dataset.next;
  }

  addActivity(activity) {
    this.feedTarget.insertAdjacentHTML("afterbegin", activity)
  }

  appendActivity(activity) {
    this.feedTarget.insertAdjacentHTML("beforeend", activity)
  }

  onNewActivity({ detail: activity }) {
    this.addActivity(activity)
  }

  loadMore() {
    this.state.cata({
      Idle: async () => {
        this.state = States.Loading;
        this.loadingIndicatorTarget.show();

        const response = await Timeline.get({ before: this.next })

        response.match({
          Success: ({ last_page, next, activities }) => {
            this.next = next;
            this.last_page = last_page;
            this.feedTarget.insertAdjacentHTML("beforeend", activities);
            if(this.last_page) {
              this.addActivity(`
                <p>${i18n.gettext("You reached the bottom!")}</p>
              `)
            }
          },
          Error: errors => console.error("Error retrieving timeline", errors),
          NetworkError: () => console.error("Could not connect to server")
        })

        this.state = (this.last_page) ? States.Finished : States.Idle;
        this.loadingIndicatorTarget.hide();
      },
      Loading: () => {},
      Finished: () => {}
    })
  }
}
