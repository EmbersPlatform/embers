import custom_emotes from "./custom_emotes";
const markdownit_emoji = require("markdown-it-emoji/lib/data/full.json");

const defs = {
  ...markdownit_emoji,
  grin: '<img class="emoji" src="/img/emotes/grin.svg">',
  ...custom_emotes.reduce((obj, item) => {
    obj[item.short_names[0]] =
      '<img class="emoji" src="' + item.imageUrl + '">';
    return obj;
  }, {})
};

export default defs;
