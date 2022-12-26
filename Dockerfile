#FROM node:16 as builder
#
#RUN mkdir -p /app
#
#WORKDIR /app
#ARG NEXTAUTH_SECRET=secret
#ARG CALENDSO_ENCRYPTION_KEY=secret
#ARG NEXTAUTH_URL='https://scheduling.hrbotfactory.com'
#ARG MAX_OLD_SPACE_SIZE=4096
#
#ENV NEXTAUTH_SECRET=${NEXTAUTH_SECRET} \
#    CALENDSO_ENCRYPTION_KEY=${CALENDSO_ENCRYPTION_KEY}
#
#COPY package.json yarn.lock turbo.json ./
#COPY packages ./packages
#COPY apps/web ./apps/web
#
#
#RUN yarn global add turbo && \
#    yarn config set network-timeout 1000000000 -g && \
#    turbo prune --scope=@calcom/web --docker && \
#    yarn --global-folder /tmp/yarn/ install
#
##RUN yarn turbo run build --filter=@calcom/web
#
#FROM node:16 as runner
#
#WORKDIR /app
#
#ARG NEXT_PUBLIC_WEBAPP_URL=http://localhost:3000
#
##ENV NODE_ENV production
#
#RUN apt-get update && \
#    apt-get -y install netcat && \
#    rm -rf /var/lib/apt/lists/* && \
#    npm install --global prisma
#
#COPY package.json yarn.lock turbo.json ./
#COPY --from=builder /app/node_modules ./node_modules
#COPY --from=builder /app/packages ./packages
#COPY --from=builder /app/apps/web ./apps/web
#COPY --from=builder /app/packages/prisma/schema.prisma ./prisma/schema.prisma
#COPY scripts scripts
#
#RUN scripts/replace-placeholder.sh http://NEXT_PUBLIC_WEBAPP_URL_PLACEHOLDER ${NEXT_PUBLIC_WEBAPP_URL}
#
##ENV NODE_ENV development
#
#RUN chmod 777 -R /app/node_modules/.cache/*
#RUN chmod 777 -R /app/node_modules/.cache/turbo
#
#COPY .env ./
#COPY .env.example ./
#COPY .env.appStore.example ./
#
#COPY --from=builder --chown=nextjs:nodejs /app/apps/web/.next ./apps/web
#
#
#EXPOSE 3000
#
#CMD ["/app/scripts/start.sh"]
#
#
#

FROM node:16 as builder

WORKDIR /calcom
ARG NEXT_PUBLIC_LICENSE_CONSENT
ARG CALCOM_TELEMETRY_DISABLED
ARG NEXTAUTH_SECRET=secret
ARG CALENDSO_ENCRYPTION_KEY=secret
ARG MAX_OLD_SPACE_SIZE=4096

ENV NEXT_PUBLIC_WEBAPP_URL=http://NEXT_PUBLIC_WEBAPP_URL_PLACEHOLDER \
    NEXT_PUBLIC_LICENSE_CONSENT=$NEXT_PUBLIC_LICENSE_CONSENT \
    CALCOM_TELEMETRY_DISABLED=$CALCOM_TELEMETRY_DISABLED \
    DATABASE_URL=$DATABASE_URL \
    NEXTAUTH_SECRET=${NEXTAUTH_SECRET} \
    CALENDSO_ENCRYPTION_KEY=${CALENDSO_ENCRYPTION_KEY} \
    NODE_OPTIONS=--max-old-space-size=${MAX_OLD_SPACE_SIZE}

COPY package.json yarn.lock turbo.json ./
COPY apps/web ./apps/web
COPY packages ./packages

RUN yarn global add turbo && \
    yarn config set network-timeout 1000000000 -g && \
    turbo prune --scope=@calcom/web --docker && \
    yarn install

RUN yarn turbo run build --filter=@calcom/web

FROM node:16 as runner

WORKDIR /calcom
ARG NEXT_PUBLIC_WEBAPP_URL=http://localhost:3000

ENV NODE_ENV production

RUN apt-get update && \
    apt-get -y install netcat && \
    rm -rf /var/lib/apt/lists/* && \
    npm install --global prisma

COPY package.json yarn.lock turbo.json ./
COPY /node_modules ./node_modules
COPY /packages ./packages
COPY /apps/web ./apps/web
COPY /packages/prisma/schema.prisma ./prisma/schema.prisma
COPY scripts scripts

# Save value used during this build stage. If NEXT_PUBLIC_WEBAPP_URL and BUILT_NEXT_PUBLIC_WEBAPP_URL differ at
# run-time, then start.sh will find/replace static values again.
ENV NEXT_PUBLIC_WEBAPP_URL=$NEXT_PUBLIC_WEBAPP_URL \
    BUILT_NEXT_PUBLIC_WEBAPP_URL=$NEXT_PUBLIC_WEBAPP_URL

RUN scripts/replace-placeholder.sh http://NEXT_PUBLIC_WEBAPP_URL_PLACEHOLDER ${NEXT_PUBLIC_WEBAPP_URL}

EXPOSE 3000
RUN yarn global add turbo
CMD ["scripts/start.sh"]
