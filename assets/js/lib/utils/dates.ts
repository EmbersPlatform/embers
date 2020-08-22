import _formatDistance from "date-fns/formatDistance";

import {es, enGB} from "date-fns/locale";

const locales = {
  "es": es,
  "en": enGB,
}

export const formatDistance = (from, to, opts = {}) => {
  const locale = document.documentElement.lang;
  return _formatDistance(from, to, {...opts, locale: locales[locale]});
}
