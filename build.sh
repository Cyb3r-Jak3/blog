#!/bin/env bash

if [[ "${CF_PAGES_BRANCH}" == "production" ]]; then
    hugo --minify
else
    hugo --minify -b "${CF_PAGES_URL}"
fi