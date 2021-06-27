import { Component } from "./component";
import Masonry from "masonry-layout";
import Imagesloaded from "imagesloaded";

export default class extends Component(HTMLElement) {
  static component = "MasonryLayout";

  grid;
  observers = [];

  onconnected() {
    const itemSelector = this.dataset.selector;
    if(!itemSelector) throw new Error("data-selector attribute not set");

    this.grid = new Masonry(this, {
      itemSelector: `masonry-layout > ${itemSelector}`,
      fitWidth: true,
      gutter: parseInt(this.dataset.gutter) || 20,
      transitionDuration: parseInt(this.dataset.transitionDuration) || 0
    });

    this.addEventListener("medialoaded", () => this.grid.layout() )

    const observe_element = element => {
      new Imagesloaded(element, () => this.grid.layout())
      const mo = new MutationObserver(() => {
        this.grid.layout();
      })
      mo.observe(element, {childList: true, subtree: true})
      this.observers.push(mo);
    }

    const mo = new MutationObserver((mutations) => {
      this.grid.reloadItems();
      this.grid.layout();
      for(let mutation of mutations) {
        mutation.addedNodes.forEach(observe_element)
      }
    })
    mo.observe(this, {childList: true})

    this.childNodes.forEach(observe_element)
  }

  ondisconnected() {
    for(let ob of this.observers) {
      ob.disconnect();
    }
  }
}
