interface ScrollOptions {
  offset?: number
}

export function scroll_into_view(element: Element, options: ScrollOptions = {}) {
  if(!options.offset)
    options.offset = (window["top-bar"].offsetHeight + 10 || 0) as number

  const offset = options.offset;
  const bodyRect = document.body.getBoundingClientRect().top;
  const elementRect = element.getBoundingClientRect().top;
  const elementPosition = elementRect - bodyRect;
  const offsetPosition = elementPosition - offset;

  window.scrollTo({
    top: offsetPosition,
    behavior: 'smooth'
  });
}
