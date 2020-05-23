import i18n from "gettext.js";
import locales from "./locales/*/*.json"

const gettext = i18n();

gettext.dgettext = function (domain, msgid) {
  return this.dcnpgettext.apply(this, [domain, undefined, msgid, undefined, undefined].concat(Array.prototype.slice.call(arguments, 1)));
}

gettext.dngettext = function (domain, msgid, msgid_plural, n) {
  return this.dcnpgettext.apply(this, [domain, undefined, msgid, msgid_plural, n].concat(Array.prototype.slice.call(arguments, 3)));
}

for (let locale_name in locales) {
  let locale = locales[locale_name];
  for (let domain in locale) {
    gettext.setMessages(domain, locale_name, locale[domain])
  }
}

export default gettext;
