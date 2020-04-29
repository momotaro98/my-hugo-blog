#!/bin/bash

set -eu

echo -e "\033[0;32mPushing to GitHub...\033[0m"

git pull origin master

cd public

git pull origin master

cd ..

git push origin master
