#!/bin/sh -e
# im.sh - check image sanity and generate a thumbnail.
# Usage: ./im.sh input-image-filename output-thumbnail-filename
# Returns a non-zero exit code if image isn't sane or something else went wrong.
# Prints a thumbnail file type to stdout: "jpg" for opaque images, "png" for
# RGBA. May produce garbage files in the output directory. The caller is
# responsible for cleanup.

die() { printf "%s\n" "$*" >&2; exit 1; }

export MAGICK_CONFIGURE_PATH=$(dirname -- "$0")

[ -f "$MAGICK_CONFIGURE_PATH/policy.xml" ] || die "$0: no policy.xml"

OPAQUE="$(identify -format '%[opaque]' "$1")"
case "$OPAQUE" in
	True)
		convert "$1" -resize 200x200\> -define jpeg:extent=8kb -strip "JPG:$2"
		echo jpg
		;;
	False)
		convert "$1" -resize 200x200\> -strip "PNG:$2"

		# Quantize.
		# Worst case: 200x200 rgba white noise -> 36kB (128 colors).
		pngnq -e ".new" -f -n 128 -- "$2"
		if [ "$(wc -c < "$2.new")" -lt "$(wc -c < "$2")" ];then
			mv -- "$2.new" "$2"
		fi

		pngcrush -s -ow "$2"

		echo png
		;;
	*)
		die "Unexpected identify output: '$OPAQUE'"
		;;
esac
