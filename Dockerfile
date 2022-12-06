FROM node:16-alpine

RUN mkdir -p /app

WORKDIR /app

COPY package.json /app

RUN echo node -v

RUN yarn

COPY . /app



RUN yarn build

EXPOSE 3000

CMD [ "yarn", "start" ]


