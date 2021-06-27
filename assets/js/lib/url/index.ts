export function build(path) {
  return new URL(path, window.location.origin);
}
