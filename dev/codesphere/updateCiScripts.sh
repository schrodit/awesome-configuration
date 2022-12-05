#!/bin/bash

set -eu

yarn build --scope @codesphere/scripts --include-dependencies
pushd packages/scripts && yarn bundleAll && popd
#git checkout \
#    packages/scripts/dist/createPaymentServiceUserToken.js \
#    packages/scripts/dist/deployLandscape.js
cp -v packages/scripts/dist/ci/*.js ci/
sed -i 's@^#!/usr/bin/env .*@#!/usr/bin/env node@' ci/*.js
