import i18n from "gettext.js";
import { build_locale } from "./locale";
import en from "./locales/en";
import es from "./locales/es";

const locales = { en, es };

const Gettext = i18n();

for (let locale_name in locales) {
  for (let domain in locales[locale_name]) {
    Gettext.setMessages(
      domain,
      locale_name,
      build_locale(locale_name, locales[locale_name][domain])
    );
  }
}

Gettext.dgettext = function (domain, msgid) {
  return this.dcnpgettext.apply(
    this,
    [domain, undefined, msgid, undefined, undefined].concat(
      Array.prototype.slice.call(arguments, 1)
    )
  );
};

Gettext.dngettext = function (domain, msgid, msgid_plural, n) {
  return this.dcnpgettext.apply(
    this,
    [domain, undefined, msgid, msgid_plural, n].concat(
      Array.prototype.slice.call(arguments, 3)
    )
  );
};

export function gettext(msgid: string, ...interpolations: string[]): string {
  return Gettext.gettext(msgid, ...interpolations);
}

export function dgettext(
  domain: string,
  msgid: string,
  ...interpolations: string[]
): string {
  return Gettext.dcnpgettext(
    domain,
    undefined,
    msgid,
    null,
    null,
    ...interpolations
  );
}

export function dngettext(
  domain: string,
  msgid: string,
  msgid_plural: string,
  n: string,
  ...interpolations: string[]
): string {
  return Gettext.dcnpgettext.apply(
    domain,
    undefined,
    msgid,
    msgid_plural,
    n,
    ...interpolations
  );
}

export default Gettext;
