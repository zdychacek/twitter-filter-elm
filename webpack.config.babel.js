import path from 'path';
import webpack from 'webpack';
import HtmlWebpackPlugin from 'html-webpack-plugin';

const dependencies = require(path.resolve(__dirname, 'package.json')).dependencies;

module.exports = {
	context: path.resolve(__dirname, 'src'),
	entry: {
		app: [
			'webpack-hot-middleware/client?reload=true',
			'index.js',
		],
		vendor: Object.keys(dependencies).filter((dep) => dep !== 'twitter'), // Dont want nodejs module inside bundle
	},
	debug: true,
	output: {
		path: path.resolve(__dirname, 'dist'),
		filename: 'app.js',
		publicPath: '/',
	},
	resolve: {
		root: path.resolve(__dirname, 'src'),
		extensions: [ '', '.js', '.elm' ],
	},
	module: {
		noParse: /\.elm$/,
		loaders: [
			{
				test: /\.elm$/,
				exclude: [ /elm-stuff/, /node_modules/ ],
				loader: 'elm-hot!elm-webpack?verbose=true&warn=true',
			},
			{
				test: /\.js$/,
				exclude: /node_modules/,
				loader: 'babel',
			},
			{
				test: /\.css/,
				loader: 'style!css',
			},
			{
				test: /\.(eot|svg|ttf|woff|woff2)$/,
				loader: 'file',
			},
		],
	},
	plugins: [
		new webpack.optimize.CommonsChunkPlugin('vendor', 'vendor.js'),
		new HtmlWebpackPlugin({ template: 'index.html', inject: 'body' }),
		new webpack.HotModuleReplacementPlugin(),
	],
};
