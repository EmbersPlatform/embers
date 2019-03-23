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

mix.setPublicPath('../priv/static');
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
mix.js("js/app.js", "js");

mix.js("js/landing.js", "js/landing");

mix.sass("sass/main.scss", "css");
mix.sass("sass/landing.scss", "css");
mix.sass("sass/out.scss", "css");

mix.copyDirectory("img", "img")
mix.copyDirectory("images", "img")
mix.copyDirectory("fonts", "img")
