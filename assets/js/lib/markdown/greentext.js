/* eslint-disable */

const GT_REGEX = /^>([^>].*)/

function locator(value, fromIndex) {
  const keep = GT_REGEX.exec(value, fromIndex)
  if (keep) {
    return value.indexOf('>', keep.index)
  }
  return -1
}

function greentextPlugin(opts = {}) {
  function inlineTokenizer(eat, value) {
    const keep = GT_REGEX.exec(value)
    if (!keep || keep.index > 0) return

    const total = keep[0]
    const greentext = keep[1]

    const node = {
      type: 'greentext',
      value: greentext,
      data: {
        hName: 'div',
        hProperties: {
          class: 'greentext',
        },
        hChildren: [{
          type: 'text',
          value: `>${greentext}`
        }]
      }
    }

    if (opts.component) {
      node.data.hName = 'greentext'
      node.data.hProperties[':greentext'] = greentext
      node.data.hProperties.href = undefined
      node.data.hChildren = []
    }

    return eat(total)(node)
  }

  inlineTokenizer.locator = locator

  const Parser = this.Parser
  const inlineTokenizers = Parser.prototype.inlineTokenizers
  const inlineMethods = Parser.prototype.inlineMethods
  inlineTokenizers.greentext = inlineTokenizer
  inlineMethods.splice(inlineMethods.indexOf('link'), 0, 'greentext')

  const Compiler = this.Compiler

  if (Compiler != null) {
    const visitors = Compiler.prototype.visitors
    visitors.greentext = function (node) {
      return `>${node.value}`
    }
  }
}

export default greentextPlugin
