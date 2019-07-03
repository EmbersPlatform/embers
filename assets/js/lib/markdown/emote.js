const emotesList = [
  'grin',
  'smutley',
  'paja',
  'shipit',
  'sanguche',
  'angrysock',
  'angry_sock',
  'horsello',
  'pepe',
  'pls',
  'dorgan',
  'hola',
  'kuru',
  'bob',
  'shock',
  'tomwat',
  'omegalul',
  'comfy'
]

const EMOTE_REGEX = new RegExp(':(' + emotesList.join('|') + '):')

function locator(value, fromIndex) {
  const keep = EMOTE_REGEX.exec(value, fromIndex)
  if (keep) {
    return value.indexOf(':', keep.index)
  }
  return -1
}

function mentionPlugin(opts = {}) {
  function inlineTokenizer(eat, value) {
    const keep = EMOTE_REGEX.exec(value)
    if (!keep || keep.index > 0) return

    const total = keep[0]
    const emote = keep[1]

    const base = opts.base || '/'

    return eat(total)({
      type: 'emote',
      value: emote,
      data: {
        hName: 'img',
        hProperties: {
          class: 'emoji',
          src: `${base}${emote}.png`
        }
      }
    })
  }

  inlineTokenizer.locator = locator

  const Parser = this.Parser
  const inlineTokenizers = Parser.prototype.inlineTokenizers
  const inlineMethods = Parser.prototype.inlineMethods
  inlineTokenizers.emote = inlineTokenizer
  inlineMethods.splice(inlineMethods.indexOf('link'), 0, 'emote')

  const Compiler = this.Compiler

  if (Compiler != null) {
    const visitors = Compiler.prototype.visitors
    visitors.emote = function (node) {
      return `${node.value}`
    }
  }
}

export default mentionPlugin
