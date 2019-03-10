#!/bin/sh

set -e

export MAGICK_CONFIGURE_PATH=$(dirname -- "$0")

[ -f "$MAGICK_CONFIGURE_PATH/policy.xml" ] || { echo "$0: no policy.xml" >&2; exit 1; }

mode=$1
fmt=$2

case "$fmt" in
	PNG|JPG) ;;
	*) echo "$0: specify valid format" >&2; exit 1;;
esac

case "$mode" in
	dimensions) exec identify -format "%w %h" "$fmt":-;;
	thumb) exec convert "$fmt":- -resize 128x128 -define jpeg:extent=8kb -strip JPG:-;;
	*) echo "$0: specify valid mode" >&2; exit 1;;
esac
