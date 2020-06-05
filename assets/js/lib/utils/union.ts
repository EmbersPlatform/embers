import {taggedSum} from "daggy";

/**
 * An object mapping the keys of `T` to a function, such that the match function
 * can make a static exhaustiveness check
 */
type MatchClauses<T> = {[K in keyof T]: Function}

/**
 * The functiosn declared in the prototype of a Union.
 */
type UnionProtoFuns<T> = {
  /** Same as match */
  cata: (any) => any,

  /** Returns a stringified version of the type. */
  toString: () => string,

  /**
   * Matches on the union type to branch the logic. Each branch takes a function
   * with the union values as arguments(in the order they were defined), that
   * will be evaluated if that branch matches the union's type.
   *
   * Match enforces exchaustiveness checking, so there must be a branch for every
   * type, otherwise match will raise an error.
   */
  match: (clauses: MatchClauses<T>) => any
}

/**
 * The functions that are part of the Union constructor
 */
type UnionFuns<T, P> = {
  /** Returns a stringified version of the type. */
  toString: () => string,
  /** Checks if the value's type matches the given constructor */
  is: (constructor: ConcreteUnion<T, P>) => boolean
}

/**
 * The function used to instantiate a concrete union type.
 */
type UnionConstructor<T, P> = (...args: any[]) => ConcreteUnion<T, P>

type ConcreteUnion<T, P> = UnionFuns<T, P> & UnionProtoFuns<T> & {[K in keyof P]: Function}

export type UnionType<T, P> = UnionConstructor<T, P> & ConcreteUnion<T, P>

export type Union<T, P> = {[K in keyof T]: UnionType<T, P>} & UnionFuns<T, P>

/**
 * Returns Type Representative containing constructors of for each key in
 * constructors as a property.
 */
export default function union<T, P = {}>(name: string, constructors: T, proto: P = {} as P): Union<T, P> {
  let tagged = taggedSum(name, constructors);

  // @ts-ignore
  tagged.prototype = {...tagged.prototype, ...proto};
  tagged.prototype.match = function(clauses) { return this.cata(clauses)}

  /**
   * Typescript is not powerful enough to understand the tricks daggy uses
   * to construct the tagged sum, so I need it to ignore the return value
   * to make it use the above type declarations instead.
   */
  // @ts-ignore
  return tagged;
}
