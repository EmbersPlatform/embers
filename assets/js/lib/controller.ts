import {Controller} from "stimulus";

const capitalize = string =>
  string[0].toUpperCase() + string.slice(1)

export class BaseController extends Controller {
  element: HTMLElement

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
