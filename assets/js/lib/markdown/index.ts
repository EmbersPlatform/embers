import unified from 'unified'
import mdParse from 'remark-parse'
import remark2rehype from 'remark-rehype'
import highlight from 'rehype-highlight'
import html from 'rehype-stringify'
import breaks from 'remark-breaks'
import emojiToShortcode from 'remark-gemoji-to-emoji'
import mdString from 'remark-stringify'

import emoji from './emoji'
import emote from './emote'
import mention from './mention'
import tag from './tag'
import post from './post'
import greentext from './greentext';

function noop() {
  return false;
}

const disabled_tokenizers = [
  'html',
  'blockquote',
  'table',
  'definition',
  'footnote',
  'atxHeading',
  'setextHeading'
]

disabled_tokenizers.forEach(tokenizer => {
  mdParse.Parser.prototype.blockTokenizers[tokenizer] = noop;
})

function htmlDecode(input) {
  var e = document.createElement('textarea');
  e.innerHTML = input;
  // handle case of empty input
  return e.childNodes.length === 0 ? "" : e.childNodes[0].nodeValue;
}

function format(input) {
  let res = unified()
    .use(mdParse, {
      gfm: true
    })
    .use(emojiToShortcode)
    .use(mdString)
    .processSync(input)

  res.contents = res.contents.split("\n").map(line => {
    if (line[0] == '\\' && (line[1] == '#' || line[1] == '>')) {
      return line.slice(1, line.length)
    } else {
      return line
    }
  }).join("\n")

  res.contents = htmlDecode(res.contents)

  res =
    unified()
    .use(mdParse)
    .use(greentext)
    .use(breaks)
    .use(emote, {
      base: '/img/emotes/',
      ext: 'png'
    })
    .use(emoji, {
      base: '/emoji/72x72/',
      ext: 'png'
    })
    .use(mention)
    .use(post)
    .use(tag)
    .use(remark2rehype)
    .use(highlight, {
      ignoreMissing: true
    })
    .use(html)
    .processSync(res.contents)

  return res.toString()
}

export default input => {
  return format(input)
}
