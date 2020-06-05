import i18n from "gettext.js";
import locales from "./locales/*/*.json"

const Gettext = i18n();

Gettext.dgettext = function (domain, msgid) {
  return this.dcnpgettext.apply(this, [domain, undefined, msgid, undefined, undefined].concat(Array.prototype.slice.call(arguments, 1)));
}

Gettext.dngettext = function (domain, msgid, msgid_plural, n) {
  return this.dcnpgettext.apply(this, [domain, undefined, msgid, msgid_plural, n].concat(Array.prototype.slice.call(arguments, 3)));
}

export function gettext(msgid: string): string {
  return Gettext.gettext(msgid);
}

export function dgettext(domain: string, msgid: string): string {
  return Gettext.dcnpgettext(domain, undefined, msgid);
}

export function dngettext(domain: string, msgid: string, msgid_plural: string, n: string): string {
  return Gettext.dcnpgettext.apply(domain, undefined, msgid, msgid_plural, n);
}

for (let locale_name in locales) {
  let locale = locales[locale_name];
  for (let domain in locale) {
    Gettext.setMessages(domain, locale_name, locale[domain])
  }
}

export default Gettext;
