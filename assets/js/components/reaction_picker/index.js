const ReactionPicker = {
  name: "ReactionPicker",
  extends: "element",

  oninit() {
    const children = Array.from(this.children)
    this.trigger = children.find(x => x.hasAttribute("trigger"))
    this.list = children.find(x => x.hasAttribute("list"))

    this.trigger.addEventListener("focus", this)
    this.addEventListener("mouseover", this)
    this.addEventListener("mouseleave", this)
    document.addEventListener("click", this)

    for(let el of this.list.children) {
      el.addEventListener("blur", this);
      el.addEventListener("click", this);
    };
  },

  onfocus() {
    this.open()
  },

  onblur(event) {
    if (this.contains(event.relatedTarget)) return;
    this.close();
  },

  onclick(event) {
    if (!this.contains(event.target)) {
      this.close();
      return;
    }
    if (this.contains(event.currentTarget)) {
      this.select_reaction(event);
    }

  },

  select_reaction(event) {
    event.preventDefault();
    event.stopPropagation();
    let reaction = event.currentTarget.dataset.reaction;
    this.close();
    this.remove_timer();
    this.dispatchEvent(new CustomEvent("select", { detail: reaction }));
  },

  start_timer() {
    if (this.timer || this.is_open) return;
    this.timer = setTimeout(() => {
      if (this.is_open) return;
      if (this.is_hovering) this.open();
    }, 500)
  },
  remove_timer() {
    clearTimeout(this.timer);
    this.timer = null;
  },

  onmouseover(event) {
    this.is_hovering = true;
    this.start_timer();
  },

  onmouseleave(event) {
    this.is_hovering = false;
    this.close();
  },

  open() {
    this.is_open = true;
    this.list.classList.add("open");
    this.remove_timer();
  },

  close() {
    this.is_open = false;
    this.list.classList.remove("open");
    this.remove_timer();
  }
}

export default ReactionPicker;
