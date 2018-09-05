import Typed from 'typed.js';

$(document).ready(() => {
	var elem = document.querySelector('#masonry');

	var msnry = new Masonry(elem, {
		"itemSelector": ".card",
		fitWidth: true,
		animationOptions: {
			duration: 50,
		}
	});

	imagesLoaded(elem)
		.on('progress', () => {
			msnry.layout();
		});
	var typed = new Typed('.typed', {
		stringsElement: '#messages-list',
		typeSpeed: 50,
		shuffle: true,
		loop: true,
		loopCount: Infinity,
		startDelay: 1000,
	})
});