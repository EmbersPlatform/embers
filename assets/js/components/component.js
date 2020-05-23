export const Base = {
  dispatch(event, data, options) {
    this.dispatchEvent(new CustomEvent(event, { ...options, detail: data }));
  }
}
