const { mix } = require('laravel-mix');
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
mix.js('js/app.js', '..\\priv/static/js')
	.extract([ 'vue', 'vue-resource', 'vuex', 'vue-router', 'axios', 'jquery' ]);

mix.js('js/landing.js', '..\\priv/static/js/landing');

mix.sass('sass/main.scss', '../priv/static/css');
mix.sass('sass/landing.scss', '../priv/static/css');
mix.sass('sass/out.scss', '../priv/static/css');
