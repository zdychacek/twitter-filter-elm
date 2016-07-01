require('babel-register');

const path = require('path');
const webpack = require('webpack');
const webpackDevMiddleware = require('webpack-dev-middleware');
const webpackHotMiddleware = require('webpack-hot-middleware');
const express = require('express');
const config = require('./webpack.config.babel.js');

const PORT = 8080;

const app = express();
const compiler = webpack(config);

const webpackMiddleware = webpackDevMiddleware(compiler, {
	publicPath: config.output.publicPath,
	contentBase: 'http://localhost:${PORT}/',
	stats: {
		colors: true,
		hash: false,
		timings: true,
		chunks: false,
		chunkModules: false,
		modules: false,
	},
});

app.use(webpackMiddleware);
app.use(webpackHotMiddleware(compiler));

const Twitter = require('twitter');
const client = new Twitter({
	consumer_key: process.env.CONSUMER_KEY,
	consumer_secret: process.env.CONSUMER_SECRET,
	bearer_token: process.env.BEARER_TOKEN,
});

app.get('/api/twitter/search/tweets.json', (req, res) => {
	client.get('search/tweets', { q: req.query.q }, (error, tweets, response) => {
		if (error) {
			res
				.status(500)
				.json({
					error,
					message: 'Twitter API responded with error',
				});
		}
		else {
			res.json(tweets);
		}
	});
});

app.get('*', (req, res) => {
	res.write(webpackMiddleware.fileSystem.readFileSync(path.join(__dirname, 'dist/index.html')));
	res.end();
});

app.listen(PORT, (err) => {
	if (err) {
		return console.log(err);
	}

	console.log(`Listening at http://localhost:${PORT}/`);
});
