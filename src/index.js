import 'materialize-css/bin/materialize.css';
import './index.css';
import Elm from './Main';

const storedState = localStorage.getItem('twitter-image-filter');
const startingState = storedState ? JSON.parse(storedState) : null;
const app = Elm.Main.fullscreen(startingState);

app.ports.saveFilters.subscribe((state) => {
	localStorage.setItem('twitter-image-filter', JSON.stringify(state));
});

app.ports.focus.subscribe((selector) => {
	const el = document.querySelector(selector);

	if (!el) {
		return;
	}

	setTimeout(() => el.focus(), 0);
});

app.ports.requestFilters.subscribe(() => {
	let filters = [];

	try {
		filters = JSON.parse(localStorage.getItem('twitter-image-filter'));
	}
	catch (ex) {
		// empty
	}

	app.ports.filtersLoaded.send(filters);
});
