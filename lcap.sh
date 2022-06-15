#!/bin/zsh

if [ -z "$1" ]; then
    echo "Missing commit message!"
    exit 1
fi

branch=$(git rev-parse --abbrev-ref HEAD)

if [ "$branch" = 'master' ] || [ "$branch" = 'main' ]; then
    echo "Create a new branch first!"
    exit 1
fi

lint_result=$(npm run lint --color=always)

if echo "$lint_result" | grep -q problem; then
    echo "Fix your linter errors!"
    echo "$lint_result"
    git reset # Unstage all changes so I don't accidentally double commit.
    exit 1
fi

commit=$(git commit -m "$1")

if echo "$commit" | grep -q "no changes"; then
    echo "Stage your changes first!"
    exit 1
fi

git push origin "$branch"

read -p "Would you like to switch to master/main from $branch? (y/n): " answer
if [[ $answer != [yY] && $answer != [yY][eE][sS] ]]; then
    exit 1
fi

checkout=$(git checkout master)

if echo "$checkout" | grep -q error; then
    git checkout main
fi
