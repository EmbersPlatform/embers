export function create(attrs, options = {}) {
  return fetch("/post", {
    method: "POST",
    body: JSON.stringify({
      ...attrs,
      _csrf_token: window.csrf_token
    }),
    headers: {
      'Accept': 'text/html',
      'Content-Type': 'application/json'
    },
    ...options
  })
}
