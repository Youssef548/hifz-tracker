#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
pnpm --filter api run spec
npx --yes @openapitools/openapi-generator-cli generate \
  -i generated/openapi.json \
  -g dart-dio \
  -o dart-packages/api_client \
  --additional-properties=pubName=hifz_api_client \
  --skip-validate-spec
(cd dart-packages/api_client && dart pub get && dart format . >/dev/null && dart fix --apply >/dev/null)
echo "api_client regenerated"
