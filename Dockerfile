FROM node:16.13.0

RUN mkdir -p /app

WORKDIR /app

COPY package.json /app

COPY turbo.json /app

COPY . /app

RUN yarn install

COPY package.json yarn.lock turbo.json /app/
COPY packages ./app/packages
COPY apps/web ./app/apps/web
COPY packages/prisma/schema.prisma ./app/prisma/schema.prisma

EXPOSE 3000

CMD ["yarn", "dev"]



