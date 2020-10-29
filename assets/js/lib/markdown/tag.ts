/* eslint-disable */

const TAG_REGEX = /#([\w+]{2,100})/

function locator(value, fromIndex) {
  const keep = TAG_REGEX.exec(value, fromIndex)
  if (keep) {
    return value.indexOf('#', keep.index)
  }
  return -1
}

function tagPlugin(opts = {}) {
  function inlineTokenizer(eat, value) {
    const keep = TAG_REGEX.exec(value)
    if (!keep || keep.index > 0) return

    const total = keep[0]
    const tag = keep[1]

    const node = {
      type: 'tag',
      value: tag,
      data: {
        hName: 'a',
        hProperties: {
          class: 'tag',
          href: `/tag/${tag}`,
          "data-name": tag
        },
        hChildren: [{
          type: 'text',
          value: `#${tag}`
        }]
      }
    }

    if (opts.component) {
      node.data.hName = 'tag'
      node.data.hProperties[':tag'] = tag
      node.data.hProperties.href = undefined
      node.data.hChildren = []
    }

    return eat(total)(node)
  }

  inlineTokenizer.locator = locator

  const Parser = this.Parser
  const inlineTokenizers = Parser.prototype.inlineTokenizers
  const inlineMethods = Parser.prototype.inlineMethods
  inlineTokenizers.tag = inlineTokenizer
  inlineMethods.splice(inlineMethods.indexOf('link'), 0, 'tag')

  const Compiler = this.Compiler

  if (Compiler != null) {
    const visitors = Compiler.prototype.visitors
    visitors.tag = function (node) {
      return `#${node.value}`
    }
  }
}

export default tagPlugin
