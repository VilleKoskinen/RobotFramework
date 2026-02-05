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
	function setColor(){
		const color = window.localStorage.getItem('color-' + form.make.value.toLowerCase());

		if (color) {
			submit.style.backgroundColor = color;
			submit.style.color = 'white';
		} else {
			submit.style.backgroundColor = 'white';
			submit.style.color = 'black';
		}
	}
	makeInput.addEventListener('input', () => {
		setColor();
	});

	const id = window.location.href.replace(/.*\//, '');
	fetch('/cars/'+ id).then(res => {
		if (res.status !== 200) {
			return Promise.reject(res.text());
		}
		else
			return res.json();
	}).then(car=> {
			form.make.value = car.make;
			form.model.value = car.model;
			form.mileage.value = car.mileage;
			form.year.value = car.year;
			form.plate.value = car.plate;
			setColor();
	})

	form.addEventListener('submit', e => {
		e.preventDefault();

		fetch('/cars/'+id, {
			method: 'PUT',
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
