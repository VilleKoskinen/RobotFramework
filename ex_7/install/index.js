'use strict';

const express = require('express');
const bodyParser = require('body-parser');
const path = require('path');
const fs = require('fs');
const util = require('util');
const crypto = require('crypto');
const {response} = require("express");

const writeFile = util.promisify(fs.writeFile);
const readFile = util.promisify(fs.readFile);

const viewDir = path.resolve(__dirname, 'views');

const app = express();
app.use(bodyParser.json());
app.use('/js', express.static(path.resolve(__dirname, 'public/js')));
app.use('/style', express.static(path.resolve(__dirname, 'public/style')));
app.use('/icon', express.static(path.resolve(__dirname, 'public/icon')));


function write(data, filePath = 'cars.json') {
	return writeFile(path.resolve(__dirname, filePath), JSON.stringify(data))
			.catch(err => console.error('Failed to write file:', err));
}


function read(filePath = 'cars.json') {
	return readFile(path.resolve(__dirname, filePath)).then(data => JSON.parse(data));
}


app.get('/', (req, res) => {
	res.sendFile('index.html', {root: viewDir});
});


app.get('/add', (req, res) => {
	res.sendFile('add.html', {root: viewDir});
});

app.get('/modify/:id', (req, res) => {
	res.sendFile('modify.html', {root: viewDir});
});

app.get('/cars', async (req, res) => {
	try {
		const cars = await read();
		res.json(cars);
	} catch (e) {
		res.status(404).send(e);
	}
});

app.put('/cars/:id', async (req, res)=> {
	try{
		const cars = await read();
		const index = cars.findIndex(c => c.id === req.params.id);
		Object.assign(cars[index], req.body);
		write(cars);
		res.json(req.body);
	}catch(e){
		res.status(404).send(e);
	}
});
app.get('/cars/:id', async (req, res) => {
	try {
		const cars = await read();
		res.send(cars.find(c => c.id === req.params.id));
	} catch (e) {
		res.status(404).send(e);
	}
});


app.post('/cars', async (req, res) => {
	const car = req.body;  // Probably unsafe to treat the entire body as a car object, but will do for the task
	//car.id = Math.floor(Math.random() * 0xffffff).toString(16);
	car.id = crypto.randomUUID();
	let cars = [];
	try {
		cars = await read();  // Blocking call to read cars
	} catch (e) {
	}

	cars.push(car);
	write(cars);  // Notice - no await, not blocking
	res.json(car);
});


app.delete('/cars/:id', async (req, res) => {
	try {
		const cars = await read();
		write(cars.filter(c => c.id !== req.params.id));
		res.sendStatus(200);
	} catch (e) {
		res.sendStatus(200);
	}
});


app.listen(3000);
console.log('Running on http://localhost:3000');
