#!/bin/env bash
set -ex;

if [ "${CF_PAGES_BRANCH}" == "master" ]; then
    hugo --minify
else
    hugo --minify -b "${CF_PAGES_URL}"
fi