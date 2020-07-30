import { html, ref } from "heresy";
import { Component } from "../component";
import random_id from "~js/lib/utils/random_id";

export default class extends Component(HTMLElement) {
  static component = "SwitchInput";
  static extends = "element";

  static booleanAttributes = ["checked", "disabled"];
  static mappedAttributes = ["checked", "disabled"];
  static observedAttributes = ["checked", "disabled"]

  _id: string;
  _children: HTMLElement[];
  _checkbox;

  checked: boolean;
  disabled: boolean;
  label: string;

  set: (boolean) => void;
  reset: () => void;

  disable: () => void;
  enable: () => void;

  onconnected() {
    super.initialize();
    if(this._in_preview) return;
    this._checkbox = ref();

    this._id = `switch-${random_id()}`;
    this._children = [].slice.call(this.childNodes);

    this.disabled = this.disabled || this.hasAttribute("disabled");
    this.checked = this.checked || this.hasAttribute("checked");

    this.label = (this._children.length)
      ? html`
        <label for=${this._id} class="switch-label">
          ${this._children}
        </label>
        `
      : ``;
  }

  onattributechanged(event) {
    console.log(event)
    switch(event.attributeName) {
      case "checked": {
        this.checked = this.hasAttribute("checked");
        break;
      }
      case "disabled": {
        this.disabled = this.hasAttribute("disabled");
        break;
      }
    }
  }

  onchecked() {
    this.render();
  }

  ondisabled() {
    this.render();
  }

  render() {
    if(this._in_preview) return;

    const onchange = event => {
      event.stopPropagation();
      this.checked = event.target.checked;
      this.dispatch("change", this.checked);
    }

    this.set = new_value => {
      this.checked = new_value;
    }

    this.reset = () => {
      this.checked = false;
    }

    this.disable = () => this.disabled = true;
    this.enable = () => this.disabled = false;

    this.html`
    <input
      ref=${this._checkbox}
      type="checkbox"
      id=${this._id}
      class="hidden"
      onchange=${onchange}
      .disabled=${this.disabled}
      .checked=${this.checked}
    >
    <label for=${this._id} class="tip"></label>
    ${this.label}
    `;
  }
}
