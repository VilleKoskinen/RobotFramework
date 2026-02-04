'use strict';


(() => {
	const carContainer = document.getElementById('car-container');


	fetch('/cars')
			.then(res => res.json())
			.then(cars => {
				for (const car of cars) {
					const carElement = document.createElement('a');
					carElement.href = '/modify/' + car.id;
					let color = window.localStorage.getItem('color-' + car.make.toLowerCase());
					if (!color) {
						color = '';
						for (let i = 0; i < 3; ++i) {
							color += Math.floor(Math.random() * 0x80).toString(16);
						}
						color = '#' + color.padStart(6, '0');
						window.localStorage.setItem('color-' + car.make.toLowerCase(), color);
					}

					carElement.innerHTML = `
                        <div class="car" style="background-color: ${color}">
                            <h3>Car</h3>
                            <div class="car-specs car-make"><span class="field-name">Make</span><span class="field-value">${car.make}</span></div>
                            <div class="car-specs car-model"><span class="field-name">Model</span><span class="field-value">${car.model}</span></div>
                            <div class="car-specs car-mileage"><span class="field-name">Mileage</span><span class="field-value">${car.mileage}</span></div>
                            <div class="car-specs car-year"><span class="field-name">Year</span><span class="field-value">${car.year}</span></div>
                            <div class="car-specs car-plate"><span class="field-name">Plate</span><span class="field-value">${car.plate}</span></div>
                        </div>
                    `;

					carElement.addEventListener('contextmenu', e => {
						e.preventDefault();

						if (confirm('Are you sure you want to delete this car?')) {
							fetch('/cars/' + car.id, {
								method: 'DELETE',
								headers: {
									'Content-Type': 'application/json'
								}
							})
									.then(res => {
										if (res.status === 200) {
											carElement.parentNode.removeChild(carElement);
										} else {
											return Promise.reject(res.text());
										}
									})
									.catch(err => console.error(err));
						}
					});

					carContainer.appendChild(carElement);
				}
			});
}).call({});
