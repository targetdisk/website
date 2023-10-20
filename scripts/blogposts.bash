#!/usr/bin/env bash

cat <<HDR
<div class="inner">
	<h1>Posts</h1>
	<dl> <!-- no longer me -->
HDR

for blog_post_md in blog/*.md; do
	date=$(grep -o '[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}' <<<"$blog_post_md")
	title=$(grep -m 1 '^#\s\+' "$blog_post_md" | sed 's/^#\s\+//')
	html=$(sed 's/\.md$/.html/' <<<"$blog_post_md")

	cat <<INNIE
		<dt>$date</dt>
			<dd><a href="$html">$title</a></dd>
INNIE
done

cat <<FTR # Short for Fetterman
	</dl> <!-- no longer on the dl -->
</div>
FTR
