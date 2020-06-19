import { Component } from "../component";

export default class FabsZone extends Component(HTMLElement) {

  oninit() {
    console.log(this)
  }

  render() {
    const scroll_top = () => {
      window.scrollTo({top:0, behavior: "smooth"})
    }

    this.html`
      <button onclick=${scroll_top} title="Scroll to top">^</button>
    `
  }
}
