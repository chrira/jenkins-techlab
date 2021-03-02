#!/bin/bash

export HUGO_VERSION=$(grep "FROM klakegg/hugo" Dockerfile | sed 's/FROM klakegg\/hugo://g' | sed 's/ AS builder//g')
docker run \
  --rm \
  -v $(pwd):/src \
  -e HUGO_RELATIVEURLS=true \
  klakegg/hugo:${HUGO_VERSION} \
  -D

export HTML_FILES=$(find public/docs/ -name '*.html')
docker run \
  --rm \
  --volume "$(pwd):/data:Z" \
  registry.puzzle.ch/puzzle/puzzled-pandoc:latest \
  pandoc ${HTML_FILE} --pdf-engine=xelatex -o jenkins-techlab.pdf


docker run \
  --rm \
  --volume "$(pwd):/data:Z" \
  --net="host" \
  registry.puzzle.ch/puzzle/puzzled-pandoc:latest \
  pandoc http://localhost:8081/docs/ --pdf-engine=xelatex -o jenkins-techlab.pdf

  # rm -rf public/
  #create_pdf -i content/en/docs/_index.md -o jenkins-techlab.pdf --from markdown --listings -V lang=ru-RU --pdf-engine=xelatex
