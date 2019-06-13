#!/bin/sh
# shellcheck disable=2039,2230

main() {
    prog=`hashcat` || err 'no hashcat'
    device=
    pw_len=6
    pw_inc=-i

    while getopts "l:d:" opt; do
	case $opt in
	    d)
		device="-d $OPTARG"
		;;
	    l)
		pw_len=$OPTARG
		pw_inc=
		;;
	    ?) exit 1
	esac
    done
    shift $((OPTIND -1))

    cmd=$1; shift

    case $cmd in
	hash)
	    echo -n "$1" | iconv -f utf8 -t utf16le | openssl md4 | awk '{print $2}'
	    ;;
	mkdict)
	    echo -n "$1" | iconv -f utf8 -t utf16le | xxd -p | tr -d '\n'
	    ;;
	unhex)
	    xxd -p -r | iconv -f utf16le -t utf8 | xargs -0 echo
	    ;;
	show)
	    $prog "$1" --show | while read -r line; do
		echo "$line" | awk -F: '{printf "%s:", $1}'
		echo "$line" | sed -E 's/.+HEX\[(.+)\]/\1/' | $0 unhex
	    done
	    ;;
	crack)
	    $prog $device --status -O -m900 -a3 --hex-charset $pw_inc \
		    -1 "`$0 mkdict "$1"`" \
		    "$2" "`mask "$pw_len"`"
	    ;;
	*)
	    err 'unknown command'
    esac
}

mask() { yes '?1' | head -$(($1*2)) | tr -d "\n"; }
hashcat() { which hashcat ./hashcat64 2>/dev/null | head -1 | grep .; }
err() { echo "$0:" "$@" 1>&2; exit 1; }

main "$@"
