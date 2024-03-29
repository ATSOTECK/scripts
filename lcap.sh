#!/bin/zsh

# Use --nt to skip emmiting translations
# Use --nl to skip running the linter

msg=$1
emitTranslations=true
runLinter=true

if [ -z "$1" ]; then
    echo "Missing commit message!"
    exit 1
fi

while test $# -gt 0; do
    case "$2" in 
        --nt) 
            shift
            emitTranslations=false
            ;;
        --nl)
            shift
            runLinter=false
            ;;
        *) break ;;
    esac
done

branch=$(git rev-parse --abbrev-ref HEAD)

if [ "$branch" = 'master' ] || [ "$branch" = 'main' ]; then
    echo "Create a new branch first!"
    exit 1
fi

if $runLinter; then
    echo "Running linter..."
    lint_result=$(npm run lint --color=always)
fi

if echo "$lint_result" | grep -q problem; then
    echo "Fix your linter errors!"
    echo "$lint_result"
    git reset # Unstage all changes so I don't accidentally double commit.
    exit 1
fi

if $emitTranslations; then
    # Unstage and re-emit translations because the auto-generated translations can be broken.
    git reset -- app/localization
    git restore app/localization
    echo "Emitting translations..."
    npm run emit-translations
    git add app/localization
fi

commit=$(git commit -m "$msg")

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
