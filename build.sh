#!/bin/bash

set -e

###################### User configured variables (required)
BLOG_PATH="public"

function copy_vault {
    ##### CHANGE START HERE
    ## Examples:
    #
    # github clone repo
    # rm -rf ./vault
    # git clone https://github.com/jmn/vault.git ./vault

    # update submodule
    # git submodule sync --recursive
    # git submodule update --init --recursive
   
    git submodule foreach git pull origin main
    ls vault
    ##### CHANGE STOP HERE.
}

## This function is called after all files are converted but before calling the Hugo command
## Use this to prepare any thing else you need before compiling the blog.
## This will be run in hugoroot.

function before_build_hook {
    # Example of things to run: hugo mod get
    echo "Nothing to do."
}

###################### Other variables
VAULT_PATH=./vault/
HUGO_ROOT=./hugoroot/
PLATFORM=$(uname)
EXPORT_BINARY=./bin/obsidian-export-$PLATFORM

####################### Process repo

echo "🍿 Obsidian to Hugo blog builder starting..."

echo "🔨 Obsidian vault path: $VAULT_PATH"
echo "🔨 Location of blog within vault: $BLOG_PATH"

HUGO_FOUND=$(which hugo)

if [ "$HUGO_FOUND" == "" ]; then
    echo "❌ Hugo not found in your system. Please install it before proceeding."
else
    echo "❇️  Hugo found in your system, proceeding."
fi

echo "🍿 Updating vault..."
copy_vault

echo "🍿 Preparing hugo root..."
mkdir -p $HUGO_ROOT/layouts/_default/_markup/
cp -Rv ./hugofiles/* $HUGO_ROOT/layouts/_default/_markup

echo "🍿 Preparing hugo content..."
rm -rf $HUGO_ROOT/content
mkdir -p $HUGO_ROOT/content
# $EXPORT_BINARY "$VAULT_PATH" --start-at "$VAULT_PATH$BLOG_PATH" --frontmatter=always $HUGO_ROOT/content/
ls ./vault
cp -Rv $VAULT_PATH$BLOG_PATH/* $HUGO_ROOT/content/

echo "✅ Converted Obsidian posts into Hugo compatible Markdown"

pushd $HUGO_ROOT > /dev/null

echo "🪝 Calling before_build_hook..."

before_build_hook

echo "🏗 Building blog..."

hugo -D 
popd > /dev/null

echo "✅ Blog built!!! Have fun!"
