DEPLOY_HTTPROOT ?= httproot
DEPLOY_BLOBS = andrea0s-plain-noextfonts.svg \
	       blob/ebrimabd.ttf \
	       blob/window-capture \
	       blob/vcf-2024-pile.jpg
AWESOME_BLOGS := -s https://lwn.net/headlines/rss \
		 -s https://lobste.rs/rss \
		 -s https://blog.haskell.org/atom.xml \
		 -s https://www.phoronix.com/rss.php \
		 -s https://static.fsf.org/fsforg/rss/news.xml \
		 -s https://emersion.fr/blog/rss.xml

UNAME = $(shell uname)
ifeq ($(UNAME),Linux)
	OPEN=xdg-open
endif

BLOG_SRC=$(wildcard blog/*.md)
BLOG_HTML=$(foreach POST,$(BLOG_SRC),$(shell scripts/htmlify.bash $(POST)))

blog/%.inner.html: blog/%.md
	pandoc --standalone --template template.html $^ -o $@

indicators: $(BLOG_SRC)
	scripts/indicators.bash

blog/%.indicator.html: indicators

blog/%.html: %.head.html nav.head.html %.indicator.html nav.tail.html window.head.html %.inner.html window.tail.html
	cat $^ > $@

vcf%.html: vcf%.head.html nav.head.html blog/vcf%.indicator.html nav.tail.html window.head.html blog/vcf%.inner.html window.tail.html
	cat $^ > $@

blog.inner.html: $(BLOG_SRC)
	scripts/blogposts.bash \
		| modules/openring/openring -n 12 -p 3 \
		  $(AWESOME_BLOGS) > $@

modules/openring/openring.go: .gitmodules
	git submodule update --init --recursive -- modules/openring

modules/openring/openring: modules/openring/openring.go
	cd modules/openring && go build

modules/resume/resume.md: .gitmodules
	git submodule update --init --recursive -- modules/resume

resume.md: modules/resume/resume.md
	tail -n+9 < $< > $@

resume.inner.html: resume.md
	pandoc --standalone --template template.html $^ -o $@

blog-posts: $(BLOG_HTML) blog.inner.html blog.html
	@echo $(BLOG_HTML)

index.html: indexhead.html nav.head.html index.indicator.html nav.tail.html index.tail.html
	cat $^ > $@

%.head.html:
	cat headhead.html > $@
	echo "<title>$* | Andrea OS</title>" >> $@
	cat headtail.html >> $@

%.html: %.head.html nav.head.html %.indicator.html nav.tail.html window.head.html %.inner.html window.tail.html
	cat $^ > $@

test: index.html
	$(OPEN) $<

$(DEPLOY_HTTPROOT)/blob:
	mkdir -p $(@)
	cp -rv $(DEPLOY_BLOBS) $(@)

deploy: all $(DEPLOY_HTTPROOT)/blob
	cp -rv *.css *.html blog media \
		$(DEPLOY_HTTPROOT)

all: blog-posts index.html blog.html resume.html vcfmw-2024.html

.PHONY: all blog-posts indicators deploy
