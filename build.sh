#!/bin/env bash
set -ex;

if [[ "${CF_PAGES_BRANCH}" == "production" ]]; then
    hugo --minify
else
    hugo --minify -b "${CF_PAGES_URL}"
fi