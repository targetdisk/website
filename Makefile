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

blog.inner.html: $(BLOG_SRC)
	scripts/blogposts.bash > $@

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

all: blog-posts index.html blog.html resume.html

.PHONY: all blog-posts indicators blog.html
