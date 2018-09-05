import twemoji from 'twemoji';
import XRegExp from 'xregexp';
import customEmojis from '../config/customEmojis';

const md = require('markdown-it')({
	linkify: true,
	typographer: true,
	breaks: false
})
.use(require('markdown-it-emoji'), {
	shortcuts: {},
	defs: {
		...require('markdown-it-emoji/lib/data/full.json'),
		'grin': '<img class="emoji" src="/img/emotes/grin.svg">',
	}
})
.disable(['table', 'image', 'reference', 'fence', 'heading', 'list']);

// setup twemoji
md.renderer.rules.emoji = (token, idx) => {
	let parsed = twemoji.parse(token[idx].content);
	return parsed.replace(/alt="(.*?)"/, '');
};

// setup linkify
md.linkify
  .tlds(require('tlds'))
  .tlds('onion', true)
  .set({ fuzzyLinks: true, fuzzyEmail: true })
  .add('@', {
	validate: (text, pos, self) => {
		const tail = text.slice(pos);

		if (!self.re.mentions)
			self.re.mentions = XRegExp('^\\pL(([\\pL\\pN][.\\-_])?[\\pL\\pN]){0,19}');

		if (self.re.mentions.test(tail)) {
			// disable `@` as @@mention is invalid
			if (pos >= 2 && tail[pos - 2] === '@')
				return false;

			return self.re.mentions.exec(tail)[0].length;
		}

		return 0;
	},

	normalize: match => {
		match.url = '/' + match.url;
	}
  })
  .add('#', {
	validate: (text, pos, self) => {
		const tail = text.slice(pos);

		if (!self.re.tags)
			self.re.tags = XRegExp('^\\pL(?:(?:[\\pL\\pN][\.\-_])?[\\pL\\pN]){1,15}');

		if (self.re.tags.test(tail)) {
			// disable `#` as ##tag is invalid
			if (pos >= 2 && tail[pos - 2] === '#')
				return false;

			return self.re.tags.exec(tail)[0].length;
		}

		return 0;
	},

	normalize: match => {
		match.url = '/search/in:' + match.url.substr(1);
	}
  });

// backup default renderer
const defaultRender = md.renderer.rules.link_open || ((tokens, idx, options, env, self) => {
		return self.renderToken(tokens, idx, options);
	});

// custom hyperlinks
md.renderer.rules.link_open = function (tokens, idx, options, env, self) {
	const attrIdx = tokens[idx].attrIndex('href'),
		href = tokens[idx].attrs[attrIdx][1];
	let matches;
	matches = /^(https?:\/\/(?:www\.|dev\.)?embers\.(?:pw|app))?(\/.*)?/.exec(href);
	if (matches[0]) {
		tokens[idx].attrPush(['data-internal-route', matches[2]]);
	} else {
		tokens[idx].attrs[attrIdx][1] = '/out?url=' + href;
		tokens[idx].attrPush(['target', '_blank']);
	}

	return defaultRender(tokens, idx, options, env, self);
};

const EXTENDED_FORMAT = ['image'];

export default {
	/**
	 * Formats greentext on the given string
	 *
	 * @deprecated Use `.format()` instead
	 * @param str
	 */
	greentext(str) {
		let regex = /^>(?!>)(.?)*$/gm;
		return str.replace(regex, '<span class="greentext">$&</span>');
	},

	/**
	 * Formats post/comment body
	 *
	 * @param body The post/comment body
	 * @param extended Whether to enable extended format
	 */
	format(body, extended = false) {
		if (body === null || !(body.toString()).length)
			return '';

		const extraFeatures = extended ? EXTENDED_FORMAT : [];
		md.enable(extraFeatures);
		var res = body.match(/^(.*?)$/gm).map(line => {
			if(line != '') {
				return md.render(line).trim();
			} else {
				return '<br />';
			}

		}).join('');
		md.disable(extraFeatures);

		res = twemoji.parse(res);

		customEmojis.forEach(emote => {
			res = res.replace(new RegExp(':'+emote.short_names[0]+':', 'g'), '<img class="emoji" src="'+emote.imageUrl+'">');
		});

		return res
	}
};