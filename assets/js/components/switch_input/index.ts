import { html, ref } from "heresy";
import { Component } from "../component";
import random_id from "~js/lib/utils/random_id";

export default class extends Component(HTMLElement) {
  static component = "SwitchInput";
  static extends = "element";

  _id: string;
  _children: HTMLElement[];
  _checkbox;

  label: string;

  set: (boolean) => void;
  reset: () => void;

  onconnected() {
    super.initialize();
    if(this._in_preview) return;
    this._checkbox = ref();

    this._id = `switch-${random_id()}`;
    this._children = [].slice.call(this.childNodes);

    this.label = (this._children.length)
      ? html`
        <label for=${this._id} class="switch-label">
          ${this._children}
        </label>
        `
      : ``;
  }

  render({useState}: Hooks) {
    if(this._in_preview) return;
    const [value, setValue] = useState(false);

    const onchange = event => {
      event.stopPropagation();
      setValue(!value);
      this.dispatch("change", !value);
    }

    this.set = new_value => {
      setValue(new_value);
      this._checkbox.current.checked = new_value;
    }

    this.reset = () => {
      this.set(false);
    }

    this.html`
    <input ref=${this._checkbox} type="checkbox" id=${this._id} class="hidden" onchange=${onchange}>
    <label for=${this._id} class="tip"></label>
    ${this.label}
    `;
  }
}
