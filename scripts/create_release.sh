#!/bin/bash
set -e

# Function to get the version from pubspec.yaml.
get_version() {
    yq e '.version' pubspec.yaml
}

old_version=$(get_version)

# Get argument for cider bump
part="$1"
if [[ -z "$part" ]]; then
    echo "Usage: $0 <part>"
    echo "part: breaking | major | minor | patch | build | pre | release"
    exit 1
fi

cider bump "$part"
new_version=$(get_version)

# Update CHANGELOG.md with the new version.
cider release

git add pubspec.yaml CHANGELOG.md

# Update the example app's dependencies.
(cd "example" && dart pub get)
git add example/pubspec.lock

# Print the version update message in yellow.
echo -e "\033[0;33mpubspec.yaml version updated from $old_version to $new_version\033[0m"

# Ask for user confirmation before pushing.
while true; do
    read -p "Are you sure you want to create and push the commit to the remote repository? (y/n): " confirm
    case "$confirm" in
    [Yy]) break ;;
    [Nn])
        echo "Aborted by user."
        exit 1
        ;;
    *) echo "Please enter y or n." ;;
    esac
done

# Create commit with the version bump and changelog update.
git commit -m "chore: release $new_version"
git tag "v$new_version"
git push

echo ""
echo -e "\033[0;32mRelease $new_version created successfully!\033[0m"
echo ""
echo -e "\033[0;32mRun ' dart format . ' to ensure all code is formatted.\033[0m"
echo -e "\033[0;32mRun ' git push origin "v$new_version" ' to publish package.\033[0m"
echo ""
