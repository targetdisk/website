#!/usr/bin/env bash

pushd blog
for post in *.md; do
	ind_name=$(sed 's/\.md$/.indicator.html/' <<<"$post")
	[ ! -a "$ind_name" ] && ln -s ../blog.indicator.html "$ind_name"
done
popd # blog
