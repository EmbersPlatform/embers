import {Component} from "~js/components/component";

export default class ReactionPicker extends Component(HTMLElement) {
  static tagName = "element";

  trigger
  list
  timer
  is_open
  is_hovering

  oninit() {
    const children = Array.from(this.children) as HTMLElement[]
    this.trigger = children.find(x => x.hasAttribute("trigger"))
    this.list = children.find(x => x.hasAttribute("list"))

    this.trigger.addEventListener("focus", this.on_focus.bind(this))
    this.addEventListener("mouseover", this.on_mouseover.bind(this))
    this.addEventListener("mouseleave", this.on_mouseleave.bind(this))
    document.addEventListener("click", this.on_click.bind(this))

    for(let el of this.list.children) {
      el.addEventListener("blur", this.on_blur.bind(this));
      el.addEventListener("click", this.on_click.bind(this));
    };
  }

  on_focus() {
    this.open()
  }

  on_blur(event) {
    if (this.contains(event.relatedTarget)) return;
    this.close();
  }

  on_click(event) {
    if (!this.contains(event.target)) {
      this.close();
      return;
    }
    if (this.contains(event.currentTarget)) {
      this.select_reaction(event);
    }
  }

  select_reaction(event) {
    event.preventDefault();
    event.stopPropagation();
    let reaction = event.currentTarget.dataset.reaction;
    this.close();
    this.remove_timer();
    this.dispatchEvent(new CustomEvent("select", { detail: reaction }));
  }

  start_timer() {
    if (this.timer || this.is_open) return;
    this.timer = setTimeout(() => {
      if (this.is_open) return;
      if (this.is_hovering) this.open();
    }, 500)
  }

  remove_timer() {
    clearTimeout(this.timer);
    this.timer = null;
  }

  on_mouseover(event) {
    this.is_hovering = true;
    this.start_timer();
  }

  on_mouseleave(event) {
    this.is_hovering = false;
    this.close();
  }

  open() {
    this.is_open = true;
    this.list.classList.add("open");
    this.remove_timer();
  }

  close() {
    this.is_open = false;
    this.list.classList.remove("open");
    this.remove_timer();
  }
}
