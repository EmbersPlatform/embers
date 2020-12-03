export default (input, sep = '-') => {
  const r = []
  let c = 0
  let p = 0
  let i = 0
  while (i < input.length) {
    c = input.charCodeAt(i++)
    if (p) {
      r.push((0x10000 + ((p - 0xd800) << 10) + (c - 0xdc00)).toString(16))
      p = 0
    } else if (c >= 0xd800 && c <= 0xdbff) {
      p = c
    } else {
      r.push(c.toString(16))
    }
  }
  return r.join(sep)
}
