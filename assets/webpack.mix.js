const { mix } = require("laravel-mix");
const webpack = require("webpack");
const path = require("path");
/*
 |--------------------------------------------------------------------------
 | Mix Asset Management
 |--------------------------------------------------------------------------
 |
 | Mix provides a clean, fluent API for defining some Webpack build steps
 | for your Laravel application. By default, we are compiling the Sass
 | file for the application as well as bundling up all the JS files.
 |
 */
mix.webpackConfig({
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "js")
    }
  },
  plugins: [
    new webpack.ProvidePlugin({
      $: "jquery",
      jQuery: "jquery",
      "window.jQuery": "jquery"
    })
  ]
});
mix.js("js/app.js", "..\\priv/static/js");

mix.js("js/landing.js", "..\\priv/static/js/landing");

mix.sass("sass/main.scss", "../priv/static/css");
mix.sass("sass/landing.scss", "../priv/static/css");
mix.sass("sass/out.scss", "../priv/static/css");
