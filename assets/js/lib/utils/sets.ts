// @ts-check

type predicate<T> = (T) => boolean
type mapper<A, B> = (value: A) => B

/**
 * Converts a Set to Array. It's equivalent to Array.from(set).
 *
 * @param {Iterable<any>} set
 * @returns {Array<any>}
 */
export function to_array(set) {
  return Array.from(set);
}

/**
 * Constructs a Set from an Iterable. It's equivalent to
 * `new Set(Array.from(collection))`.
 */
export function from<T>(collection: Iterable<T>): Set<T> {
  return new Set(Array.from(collection));
}

/**
 * Applies a mapper function to every element of the Set and returns a new Set
 * with them.
 */
export function map<T, U>(set: Set<T>, mapper: mapper<T, U>): Set<U> {
  const new_set = new Set<U>();
  for(let value of set) {
    new_set.add(mapper(value));
  }
  return new_set;
}

/**
 * Returns true if at least one element from the set satisfies the predicate.
 *
 * @template T
 * @param {Set<T>} set
 * @param {predicate<T>} predicate
 * @returns {boolean}
 */
export function any(set, predicate) {
  for(let value of set) {
    if(predicate(value)) return true;
  }
  return false;
}

/**
 * Returns true if all elements of the set satisfy the predicate.
 *
 * @template T
 * @param {Set<T>} set
 * @param {predicate<T>} predicate
 * @returns {boolean}
 */
export function all(set, predicate) {
  for(let value of set) {
    if(!predicate(value)) return false;
  }
  return true;
}

/**
 *
 * @param {Set<string>} set
 * @param {string} needle
 */
export function has_insensitive(set, needle) {
  return any(set,
    value => value.toLowerCase() === needle.toLowerCase()
  );
}

/**
 * Deletes a needle from a set of strings, ignoring the casing.
 * This function mutates the original set.
 *
 * @param {Set<string>} set
 * @param {string} needle
 * @returns {Set<string>}
 */
export function delete_insensitive(set, needle) {
  const val = find(set, v => v.toLowerCase() === needle.toLowerCase());
  set.delete(val);
  return set;
}

/**
 * Returns the element that satisfies the predicate, or `undefined` if none is
 * found.
 *
 * @template T
 * @param {Set<T>} set
 * @param {predicate<T>} predicate
 * @returns {T}
 */
export function find(set, predicate) {
  for(let value of set) {
    if(predicate(value)) return value;
  }
  return undefined;
}

/**
 * Returns a new Set with the elements that satisfy the predicate.
 */
export function filter<T>(set: Set<T>, predicate: predicate<T>): Set<T> {
  const new_set = new Set<T>();
  for(let elem of set) {
    if(predicate(elem))
      new_set.add(elem);
  }
  return new_set;
}

/**
 * Does the opposite of filter, creating a new Set with the elements that don't
 * satisfy the predicate.
 *
 * @template T
 * @param {Set<T>} set
 * @param {predicate<T>} predicate
 * @returns {Set<T>}
 */
export function reject(set, predicate) {
  const new_set = new Set();
  for(let elem of set) {
    if(!predicate(elem))
      new_set.add(elem);
  }
  return new_set;
}

/**
 * Joins the set elements to a string.
 *
 * @param {Set<string>} set
 * @param {string} joiner
 * @returns {string}
 */
export function join(set, joiner = ",") {
  return to_array(set).join(joiner);
}

/**
 * Returns a new set containing the values of both sets.
 *
 * @param {Set} set1
 * @param {Set} set2
 * @returns {Set}
 */
export function union(set1, set2) {
  let new_set = new Set(set1);
  for (let elem of set2) {
    new_set.add(elem);
  }
  return new_set;
}

/**
 * Returns a new set of objects deduplicated by their `property`.
 *
 * @param {Set<Object>} set
 * @param {any} property
 * @returns {Set<Object>}
 */
export function uniq_by(set, property) {
  let properties = new Set();

  return filter(set, value => {
    const property_value = value[property];

    if(properties.has(property_value)) {
      return false;
    } else {
      properties.add(property_value);
      return true;
    }
  })
}

/**
 * Returns a new set of objects with the values not included in the other set,
 * comparing elements by the given `property`.
 *
 * @param {Set<Object>} set1
 * @param {Set<Object>} set2
 * @param {any} property
 * @returns {Set<Object>}
 */
export function difference_by(set1, set2, property) {
  return filter(set1, value => {
    if(any(set2, x => x[property] === value[property])) {
      return false;
    }
    return true;
  })
}
