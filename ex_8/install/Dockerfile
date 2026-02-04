FROM node:slim

WORKDIR /usr/src/app

COPY package*.json ./

RUN npm install

COPY . .

EXPOSE 3000

CMD ["node", "index.js"]
#Below are commands to run the docker container
#docker build . -t josephh/node-web-app  
#docker run -p 49160:3000 -d josephh/node-web-app 
