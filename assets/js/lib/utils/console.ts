export function log(...args) {
  if (process.env.NODE_ENV !== "production") return console.debug(...args);
}
