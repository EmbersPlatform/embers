/* eslint-disable */

const POST_REGEX = />>([a-zA-Z0-9]*)/

function locator(value, fromIndex) {
  const keep = POST_REGEX.exec(value, fromIndex)
  if (keep) {
    return value.indexOf('>>', keep.index)
  }
  return -1
}

function postPlugin(opts = {}) {
  function inlineTokenizer(eat, value) {
    const keep = POST_REGEX.exec(value)
    if (!keep || keep.index > 0) return

    const total = keep[0]
    const post = keep[1]

    const node = {
      type: 'post',
      value: post,
      data: {
        hName: 'a',
        hProperties: {
          class: 'post-ref',
          href: `/post/${post}`
        },
        hChildren: [{
          type: 'text',
          value: `>>${post}`
        }]
      }
    }

    if (opts.component) {
      node.data.hName = 'post'
      node.data.hProperties[':post'] = post
      node.data.hProperties.href = undefined
      node.data.hChildren = []
    }

    return eat(total)(node)
  }

  inlineTokenizer.locator = locator

  const Parser = this.Parser
  const inlineTokenizers = Parser.prototype.inlineTokenizers
  const inlineMethods = Parser.prototype.inlineMethods
  inlineTokenizers.post = inlineTokenizer
  inlineMethods.splice(inlineMethods.indexOf('link'), 0, 'post')

  const Compiler = this.Compiler

  if (Compiler != null) {
    const visitors = Compiler.prototype.visitors
    visitors.post = function (node) {
      return `>>${node.value}`
    }
  }
}

export default postPlugin
