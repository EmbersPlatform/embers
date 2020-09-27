// @ts-check
import { define } from "heresy";
import stateHandler from "reactive-props";

export const register = component => {
  // Hack, since class names get transpiled and the name property can't
  // be overriden, just dinamically set it to whatever the static `component`
  // property is.
  // Why the hell are class names minified anyways?
  const name = component.component;
  Object.defineProperty(component, 'name', {
    writable: true,
    value: name
  });
  define(component)
}

/**
 * It would be nice to use Typescript here too, but it completely fucks
 * transpiling and extending native elements.
 */

/**
 * @typedef {Object & HTMLElement} Base
 *
 * @prop {string} [name]
 * @prop {string} [extends]
 * @prop {Object} [includes]
 * @prop {string[]} [booleanAttributes]
 *
 * @prop {function} [oninit]
 * @prop {function} [onconnected]
 * @prop {function} [ondisconnected]
 * @prop {function} [handleEvent]
 *
 * @prop {function} dispatch
 *
 */

 /**
  * @deprecated Extend {@link Component<T>} instead
  * @type {Base}
  */
export const Base = {
  dispatch(event, data, options) {
    this.dispatchEvent(new CustomEvent(event, { ...options, detail: data }));
  }
}

/**
 * @template T
 * @typedef {new (...args: any[]) => T} Constructor
 */


/**
 * Creates a base class for other components to extend, based on
 * [WebReflection/heresy]{@link https://github.com/WebReflection/heresy}.
 *
 * @template {Constructor<HTMLElement>} T
 * @param {T} superclass - The HTMLElement or derivative class to extend from.
 */
export const Component = (superclass) => {
  if(typeof superclass !== "function")
    throw new TypeError(`Expected argument to be a class constructor, got ${typeof superclass}`);

  if(superclass !== HTMLElement && !(superclass.prototype instanceof HTMLElement))
    throw new TypeError(`Base class must implement HTMLElement interface.`);

  /**
   * @class
   * @extends {superclass}
   */
  return class extends superclass {

    _in_preview = false;

    initialize() {
      this._in_preview = document.documentElement.hasAttribute("data-turbolinks-preview");
    }

    /**
     * Dispatchs a `CustomEvent` with `data` as it's `detail` property.
     * Returns true if either event's cancelable attribute value is false or its
     * preventDefault() method was not invoked, and false otherwise.
     *
     * @param {string} event
     * @param {*} [data]
     * @param {CustomEventInit} [options]
     * @return {boolean}
     */
    dispatch(event, data, options) {
      return this.dispatchEvent(new CustomEvent(event, { ...options, detail: data }));
    }

    /**
     * Use `this.html` tagged template literal to render html contents to the
     * component.
     * @param  {...any} _args
     */
    html(..._args) {}

    /**
     * Use `this.svg` tagged template literal to render svg contents to the
     * component.
     * @param  {...any} _args
     */
    svg(..._args) {}

    /**
     * See {@link https://developer.mozilla.org/en-US/docs/Web/API/EventListener/handleEvent}
     *
     * The `EventListener` method `handleEvent()` method is called by the user
     * agent when an event is sent to the `EventListener`, in order to handle
     * events that occur on an observed `EventTarget`.
     *
     * @param {Event} event
     * An `Event` object describing the event that has been fired and needs
     * to be processed.
     *
     * @returns {void} If you return a value, the browser will ignore it.
     */
    handleEvent(event) {
      this[`on${event.type}`](event);
    }

    /**
     * @param {Hooks} [hooks]
     */
    render(hooks) {}
  }
}

/**
 *
 *
 * @function
 * @template T
 * @param {T} state
 * @param {Function} callback
 * @returns {T}
 */
export const reactive = (state, callback) =>
  stateHandler()(state, callback);
