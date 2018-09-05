const webpack = require('webpack');
module.exports = {
	loaders: [],
	plugins: [
		new webpack.ProvidePlugin({
			$: 'jquery',
			jQuery: 'jquery',
			'window.jQuery': 'jquery'
		})
	]
};