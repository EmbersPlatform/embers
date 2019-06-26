import unified from 'unified'
import mdParse from 'remark-parse'
import mdString from 'remark-stringify'
import remark2rehype from 'remark-rehype'
import highlight from 'rehype-highlight'
import html from 'rehype-stringify'
import emojiToShortcode from 'remark-gemoji-to-emoji'
import disableTokens from 'remark-disable-tokenizers'

import emoji from './emoji'
import emote from './emote'
import mention from './mention'
import tag from './tag'
import post from './post'
import greentext from './greentext';

function strip_html(str) {
  if ((str === null) || (str === ''))
    return false;
  else
    str = str.toString();
  return str.replace(/<[^>]*>/g, '');
}

function escapeHtml(html) {
  var text = document.createTextNode(html);
  var p = document.createElement('p');
  p.appendChild(text);
  return p.innerHTML;
}

export default input => {
  let res = unified()
    .use(mdParse, {
      gfm: true
    })
    .use(disableTokens, {
      block: [
        'indentedCode',
        'blockquote',
        'atxHeading',
        'list',
        'html',
        'table',
      ],
    })
    .use(emojiToShortcode)
    .use(mdString)
    .processSync(input)

  res = res.toString()
  res = res.split("\n").map(line => {
    if (line[0] == '\\' && (line[1] == '#' || line[1] == '>')) {
      return line.slice(1, line.length)
    } else {
      return line
    }
  }).join("\n")

  console.log(res)

  res = unified()
    .use(mdParse)
    .use(disableTokens, {
      block: [
        'list', 'indentedCode', 'html', 'atxHeading', 'setextHeading', 'table', 'blockquote'
      ]
    })
    .use(greentext)
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
    .processSync(res)

  return res.toString()
}
