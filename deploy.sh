#!/bin/bash

set -eu

echo -e "\033[0;32mDeploying updates to GitHub...\033[0m"

user_name="momotaro98"

echo 'Set Git configurations'
git config --global user.name $user_name
git config --global user.email ${EMAIL_ADDRESS}

echo 'Start deploying onto hosting service'

cd public

# Check if there's change in the generated artifact
if [[ ! `git status --porcelain` ]]; then
  echo 'No change in artifact then finishing this deploying workflow'
  exit 0
fi

git remote set-url origin https://$user_name:${DEPLOY_TOKEN}@github.com/$user_name/$user_name.github.io.git
git checkout master
git add .

msg="rebuilding site `date`"
if [ $# -eq 1 ]
  then msg="$1"
fi
git commit -m "$msg"

git push origin HEAD

echo 'Deploy done'

echo 'Start doing git commit to master itself'

cd ..
git remote set-url origin https://$user_name:${GITHUB_TOKEN}@github.com/$user_name/my-hugo-blog.git
git checkout master
git add public
git commit -m "Deploy public `date`"
git push origin HEAD

echo 'Git commit done'
