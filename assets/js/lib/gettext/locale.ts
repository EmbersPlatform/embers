export const build_locale = (language, translations) => ({
  "": {
    language,
    "plural-forms": "nplurals = 2; plural = (n != 1);",
  },
  ...translations,
});
