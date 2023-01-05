#!/bin/sh
set -e

pnpm exec tsc
cp package.json pnpm-lock.yaml index.html dist/
(cd dist && pnpm install --prod --frozen-lockfile)
(cd dist && zip -r ../dist.zip *)
