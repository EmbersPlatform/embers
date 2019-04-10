let mix = require('laravel-mix');
mix.setPublicPath('../../priv/static/admin');

mix.webpackConfig({
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "src")
    }
  }
});

mix.js('src/app.js', 'js/').sass('src/styles/main.scss', 'css/');
