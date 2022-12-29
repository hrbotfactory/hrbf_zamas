#!/bin/sh
set -x

scripts/replace-placeholder.sh "$BUILT_NEXT_PUBLIC_WEBAPP_URL" "$NEXT_PUBLIC_WEBAPP_URL"

npx prisma migrate deploy --schema ./packages/prisma/schema.prisma
npx ts-node --transpile-only ./packages/prisma/seed-app-store.ts
yarn start
