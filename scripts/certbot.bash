#!/usr/bin/env bash

DOMAIN='targetdisk.io'
CLOUDFLARE_SECRET_INI='/root/.super-secret/cloudflare.ini'

install_certbot() {
	[ "$1" == help ] && echo -n "Install certbot via Pip." && return 0
	[ $UID -ne 0 ] && die "ERROR: must be root!"

	mkdir -p ~/src

	pip install --user --upgrade pip
	pip install --upgrade certbot

	git clone --recurse-submodules \
		https://github.com/cloudflare/certbot-dns-cloudflare \
		~/src/certbot-dns-cloudflare

	pushd ~/src/certbot-dns-cloudflare
	python3 setup.py install
	popd  # ~/src/certbot-dns-cloudflare
}

setup_certbot() {
	[ "$1" == help ] && echo -n "Setup certbot with Cloudflare DNS." && return 0
	[ $UID -ne 0 ] && die "ERROR: must be root!"

	[ -f "$CLOUDFLARE_SECRET_INI" ] \
		|| dedcat  "ERROR: Please ensure you have a \"$CLOUDFLARE_SECRET_INI\" file!"$'\n' \
			  $'  For more information see here:\n' \
			  $'      https://developers.cloudflare.com/fundamentals/api/get-started/\n\n' \
			  $'  And here:\n' \
			   '      https://labzilla.io/blog/cloudflare-certbot'

	certbot certonly --dns-cloudflare \
		--dns-cloudflare-credentials "$CLOUDFLARE_SECRET_INI" \
		-d "$DOMAIN,*.$DOMAIN" \
		--preferred-challenges dns-01
}

# TODO: Check back when Go/Cloudflare get their heads our of their arses
install_cloudflared() {
	[ "$1" == help ] && echo -n "Setup cloudflared." && return 0
	[ $UID -ne 0 ] && die "ERROR: must be root!"

	# Alpine+Cloudflare+Go made me do this
	wget -O /usr/local/bin/cloudflared \
		'https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64'

	# We really should be checking a checksum/sig before doing this...
	# Oh well...
	chmod +x /usr/local/bin/cloudflared

	# If you hack Cloudflare's GitHub/devs you honestly deserve the keys to my little
	# kingdom... ¯\_(ツ)_/¯
}
