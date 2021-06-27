import {Controller} from "stimulus";

const capitalize = string =>
  string[0].toUpperCase() + string.slice(1)

export class BaseController extends Controller {
  element: HTMLElement

  _in_preview = false;

  connect() {
    this._in_preview = document.documentElement.hasAttribute("data-turbolinks-preview");
  }

  get_target<T = HTMLElement>(target: string): T | undefined {
    return this[`${target}Target`];
  }

  /**
   * @param {string} target
   * @returns {boolean}
   */
  has_target(target: string): boolean {
    const target_name = capitalize(target);
    return this[`has${target_name}Target`];
  }
}
