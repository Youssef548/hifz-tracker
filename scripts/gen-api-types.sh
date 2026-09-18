#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
pnpm --filter api run spec
mkdir -p packages/api-sdk/src/generated
pnpm --filter @hifz/api-sdk exec openapi-typescript \
  ../../generated/openapi.json \
  -o src/generated/schema.d.ts
echo "api-sdk types regenerated"
