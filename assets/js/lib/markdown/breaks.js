'use strict'

module.exports = breaks

function breaks() {
  var parser = this.Parser
  var tokenizers

  if (!isRemarkParser(parser)) {
    throw new Error('Missing parser to attach `remark-github-break` to')
  }

  tokenizers = parser.prototype.inlineTokenizers
  tokenizeBreak.locator = tokenizers.break.locator
  tokenizers.break = tokenizeBreak

  function tokenizeBreak(eat, value, silent) {
    var length = value.length
    var index = -1
    var queue = ''
    var character
    var chunk

    while (++index < length) {
      character = value.charAt(index)
      chunk = queue.substring(queue.length - 2, queue.length)

      if (character === '\n' && chunk === '  ') {
        /* istanbul ignore if - never used (yet) */
        if (silent) {
          return true
        }
        return eat(chunk + character)({
          type: 'break'
        })
      }

      chunk = queue.substring(queue.length - 1, queue.length)
      if (character === '\n' && chunk === '\\') {
        /* istanbul ignore if - never used (yet) */
        if (silent) {
          return true
        }
        return eat(chunk + character)({
          type: 'break'
        })
      }

      if (character !== ' ' && character !== '\\') {
        return
      }
      queue += character
    }
  }
}

function isRemarkParser(parser) {
  return Boolean(
    parser &&
    parser.prototype &&
    parser.prototype.inlineTokenizers &&
    parser.prototype.inlineTokenizers.break &&
    parser.prototype.inlineTokenizers.break.locator
  )
}
