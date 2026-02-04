'use strict';


(() => {
	const makes = [
		'kia',
		'volkswagen',
		'nissan',
		'volvo',
		'hyundai',
		'honda',
		'tesla',
		'bmw',
		'renault',
		'skoda',
		'ford'
	];
	const form = document.getElementById('add-form');
	const submit = document.querySelector('input[type="submit"]');
	const makeInput = document.getElementById('make-input');
	const cancel = document.querySelector('input[type="Button"]');

	makeInput.addEventListener('input', () => {
		const color = window.localStorage.getItem('color-' + form.make.value.toLowerCase());

		if (color) {
			submit.style.backgroundColor = color;
			submit.style.color = 'white';
		} else {
			submit.style.backgroundColor = 'white';
			submit.style.color = 'black';
		}
	});


	form.addEventListener('submit', e => {
		e.preventDefault();

		fetch('/cars', {
			method: 'POST',
			headers: {
				'Content-Type': 'application/json'
			},
			body: JSON.stringify({
				make: form.make.value,
				model: form.model.value,
				mileage: form.mileage.value,
				year: form.year.value,
				plate: form.plate.value
			})
		})
				.then(res => {
					if (res.status !== 200) {
						return Promise.reject(res.text());
					}
					window.location.href = '/';
				})
				.catch(err => console.error(err));
	});
	cancel.addEventListener('click', e => {
		e.preventDefault();
		window.location.href = '/';
	})
}).call({});
