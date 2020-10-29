/* eslint-disable */

const MENTION_REGEX = /@([-\w]*(?:\w+)*)(?!\S)/

function locator(value, fromIndex) {
  const keep = MENTION_REGEX.exec(value, fromIndex)
  if (keep) {
    return value.indexOf('@', keep.index)
  }
  return -1
}

function mentionPlugin(opts = {}) {
  function inlineTokenizer(eat, value) {
    const keep = MENTION_REGEX.exec(value)
    if (!keep || keep.index > 0) return

    const total = keep[0]
    const username = keep[1]

    const node = {
      type: 'mention',
      value: username,
      data: {
        hName: 'emb-mention',
        hProperties: {
          "data-name": username
        },
      }
    }

    if (opts.component) {
      node.data.hName = 'usermention'
      node.data.hProperties[':user'] = username
      node.data.hProperties.href = undefined
      node.data.hChildren = []
    }

    return eat(total)(node)
  }

  inlineTokenizer.locator = locator

  const Parser = this.Parser
  const inlineTokenizers = Parser.prototype.inlineTokenizers
  const inlineMethods = Parser.prototype.inlineMethods
  inlineTokenizers.mention = inlineTokenizer
  inlineMethods.splice(inlineMethods.indexOf('link'), 0, 'mention')

  const Compiler = this.Compiler

  if (Compiler != null) {
    const visitors = Compiler.prototype.visitors
    visitors.mention = function (node) {
      return `@${node.value}`
    }
  }
}

export default mentionPlugin
