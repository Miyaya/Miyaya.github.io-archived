#!/bin/bash

# Path to your Hugo project
PROJECT_PATH="/Users/miyalee/Documents/GitHub/Miyaya.github.io"

# Generate the static pages with Hugo
hugo -d public

# Clone the GitHub Pages branch
git clone https://github.com/miyaya/miyaya.github.io.git --branch gh-pages public

# Remove existing content
rm -rf public/*

# Copy new content
cp -r ${PROJECT_PATH}/public/* public

# Add new content
cd public
git add .

# Commit changes
git commit -m "try deploy.sh"
git push origin gh-pages

# Clean up
cd ..
rm -rf public
