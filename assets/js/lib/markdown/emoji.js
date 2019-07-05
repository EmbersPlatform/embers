import EmojiRegExp from 'emoji-regex'
import e2u from './e2u'

function locator(value, fromIndex) {
  return value.search(EmojiRegExp())
}

function emojiPlugin(opts = {}) {
  function inlineTokenizer(eat, value) {
    const keep = EmojiRegExp().exec(value)
    if (!keep || keep.index > 0) return

    const total = keep[0]
    const emoji = keep[0]

    const codepoint = e2u(emoji)

    const base = opts.base || '/'
    const ext = opts.ext || 'png'

    return eat(total)({
      type: 'emote',
      value: emoji,
      data: {
        hName: 'img',
        hProperties: {
          class: 'emoji',
          src: `${base}${codepoint}.${ext}`
        }
      },
      children: []
    })
  }

  inlineTokenizer.locator = locator

  const Parser = this.Parser
  const inlineTokenizers = Parser.prototype.inlineTokenizers
  const inlineMethods = Parser.prototype.inlineMethods
  inlineTokenizers.emoji = inlineTokenizer
  inlineMethods.splice(inlineMethods.indexOf('link'), 0, 'emoji')

  const Compiler = this.Compiler

  if (Compiler != null) {
    const visitors = Compiler.prototype.visitors
    visitors.emoji = function (node) {
      return `${node.value}`
    }
  }
}

export default emojiPlugin
