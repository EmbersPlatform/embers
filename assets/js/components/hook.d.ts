declare type useState = <T>(initialValue: T) => [T, (newState: T) => void];
declare type useEffect = (effect: Function, inputs?: Array<any>) => void;
declare type useReducer = <T>(
  reducer: (state: T, action: Object) => T,
  initialState: T,
  initialAction?: Object,
) => [T, (action: Object) => void];
declare type useCallback = (callback: Function, inputs: Array<any>)=> Function;
declare type useMemo = <T>(memoized: Function, inputs: Array<any>) => T;

declare type Hooks = {
  useState: useState,
  useEffect: useEffect,
  useReducer: useReducer,
  useCallback: useCallback,
  useMemo: useMemo
}
