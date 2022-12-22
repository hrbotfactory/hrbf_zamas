FROM node:16 as builder

RUN mkdir -p /app

WORKDIR /app
ARG NEXTAUTH_SECRET=secret
ARG CALENDSO_ENCRYPTION_KEY=secret
ARG NEXTAUTH_URL='http://localhost:3000'

ENV NEXTAUTH_SECRET=${NEXTAUTH_SECRET} \
    CALENDSO_ENCRYPTION_KEY=${CALENDSO_ENCRYPTION_KEY}

COPY package.json yarn.lock turbo.json ./
COPY packages ./packages
COPY apps/web ./apps/web


RUN yarn global add turbo && \
    yarn config set network-timeout 1000000000 -g && \
    turbo prune --scope=@calcom/web --docker && \
    yarn --global-folder /tmp/yarn/ install

#RUN yarn turbo run build --filter=@calcom/web

FROM node:16 as runner

WORKDIR /app

ARG NEXT_PUBLIC_WEBAPP_URL=http://localhost:3000

#ENV NODE_ENV production

RUN apt-get update && \
    apt-get -y install netcat && \
    rm -rf /var/lib/apt/lists/* && \
    npm install --global prisma

COPY package.json yarn.lock turbo.json ./
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/packages ./packages
COPY --from=builder /app/apps/web ./apps/web
COPY --from=builder /app/packages/prisma/schema.prisma ./prisma/schema.prisma
COPY scripts scripts

RUN scripts/replace-placeholder.sh http://NEXT_PUBLIC_WEBAPP_URL_PLACEHOLDER ${NEXT_PUBLIC_WEBAPP_URL}

ENV NODE_ENV development

RUN chmod 777 -R /app/node_modules/.cache/*
RUN chmod 777 -R /app/node_modules/.cache/turbo

COPY .env ./
COPY .env.example ./
COPY .env.appStore.example ./

EXPOSE 3000

CMD ["/app/scripts/start.sh"]



