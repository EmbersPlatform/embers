import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["editor", "feed", "loadMoreButton"]

  getLastId() {
    let activities = this.feedTarget.children;
    return activities[activities.length - 1].dataset.id;
  }

  addActivity(activity) {
    this.feedTarget.insertAdjacentHTML("afterbegin", activity)
  }

  onNewActivity({ detail: activity }) {
    this.addActivity(activity)
  }

  loadMore() {
    console.log("Load more activities...", this.last_id)
    this.loadMoreButtonTarget.disabled = true;
    setTimeout(() => {
      this.loadMoreButtonTarget.disabled = false;
    }, 1000)
  }
}
