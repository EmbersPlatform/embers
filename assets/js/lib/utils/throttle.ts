export default function throttle<A extends any[], R>(fn: (...args: A) => R , wait: number): (...args: A) => R {
  let previouslyRun, queuedToRun;

  return function invokeFn(...args): R {
      const now = Date.now();

      queuedToRun = clearTimeout(queuedToRun);

      if (!previouslyRun || (now - previouslyRun >= wait)) {
        previouslyRun = now;
        return fn.apply(null, args);
      } else {
          queuedToRun = setTimeout(invokeFn.bind(null, ...args), wait - (now - previouslyRun));
      }
  }
};
