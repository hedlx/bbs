#!/bin/sh

set -e

die() { printf "%s\n" "$*" >&2; exit 1; }

export MAGICK_CONFIGURE_PATH=$(dirname -- "$0")

[ -f "$MAGICK_CONFIGURE_PATH/policy.xml" ] || die "$0: no policy.xml"

convert "$1" -resize 200x200 -define jpeg:extent=8kb -strip "JPG:$2"
