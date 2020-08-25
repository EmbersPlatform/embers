import { define } from "wicked-elements";
import * as Fetch from "~js/lib/utils/fetch";
import s from "flyd";

define("[infinite-scroll]", {
  connected() {
    this.streams = [];
    this.next = this.element.dataset.next;
    this.last_page = this.element.dataset.lastPage == "true";

    this.source = this.element.dataset.source;
    this.cursor = this.element.dataset.cursor || "before";
    this.insertion_point = this.element.dataset.insertionPoint || "beforeend";

    document.addEventListener("DOMContentLoaded", () => {
      this.viewport = this.element.querySelector("[infinite-scroll-viewport]");
      this.indicator = this.element.querySelector("[infinite-scroll-indicator]");
      this.observer = this.element.querySelector("[infinite-scroll-intersect]");

      this.loading = s.stream();

      this.streams.push(
        s.on(loading => {
          if(!this.indicator) return;
          loading
            ? this.indicator.show()
            : this.indicator.hide();
        }, this.loading)
      );

      this.load_more = load_more.bind(this);

      this.observer.addEventListener("intersect", this.load_more);

    })

  }

  ,disconnected() {
    this.observer.removeEventListener("intersect", this.load_more);
    this.streams.forEach(stream => stream.end(true));
  }
});

async function load_more() {
  if(this.last_page) return;
  if(this.loading()) return;

  this.loading(true);

  let params = {entries: true};
  params[this.cursor] = this.next;

  const response = await Fetch.get(this.source, {params})
  if(response.tag !== "Success") return;

  const page = await Fetch.parse_pagination(response.value);

  this.next = page.next;
  this.last_page = page.last_page;

  this.viewport.insertAdjacentHTML(this.insertion_point, page.body);

  this.loading(false);
}
