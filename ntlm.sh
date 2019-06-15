#!/bin/sh
# shellcheck disable=2039,2230

main() {
    prog=`hashcat` || err 'no hashcat'
    pw_len=6
    pw_inc=-i

    while getopts "l:" opt; do
	case $opt in
	    l) pw_len=$OPTARG
	       pw_inc=
	       ;;
	    ?) exit 1
	esac
    done
    shift $((OPTIND - 1))

    cmd=$1; shift

    case $cmd in
	hash)
	    check_params "$1"
	    echo -n "$1" | utf16le | openssl md4 | awk '{print $2}'
	    ;;
	mkcharset)
	    check_params "$1"
	    echo -n "$1" | utf16le | xxd -p -c1 | sort -u | tr -d '\n'
	    ;;
	unhex)
	    input=`cat`
	    echo "$input" | unhex_aggressive > /dev/null 2>&1 && {
		echo "$input" | unhex_aggressive | xargs echo; return
	    }
	    echo "$input" | xxd -p -r | xargs echo # ascii
	    ;;
	show)
	    check_params "$1"
	    "$prog" "$1" --show | while read -r line; do
		echo "$line" | awk -F: '{printf "%s:", $1}'
		pw=`echo "$line" | sed -E 's/[^:]+://'`
		if [ "${pw:0:5}" = "\$HEX[" ] ; then
		   echo "${pw:5:-1}" | $0 unhex
		else
		    echo "$pw"
		fi
	    done
	    ;;
	crack)
	    check_params "$1" "$2"
	    cs=`if [ -r "$1" ]; then echo "$1"; else $0 mkcharset "$1"; fi`
	    hash=$2
	    shift 2
	    `cygwinaze "$prog"` -O -m900 -a3 --hex-charset $pw_inc \
				-1 "$cs" "$hash" "`mask "$pw_len"`" "$@"
	    ;;
	*)
	    err 'what?'
    esac
}

mask() { yes '?1' | head -$(($1*2)) | tr -d "\n"; }
hashcat() { path hashcat ./hashcat64 | head -1 | grep .; }
cygwinaze() {
    uname | grep -q CYGWIN && path winpty && { echo "winpty $1"; return; }
    echo "$1"
}
err() { echo "$0:" "$@" 1>&2; exit 1; }
path() { which "$@" 2>/dev/null; }
unhex_aggressive() { xxd -p -r | iconv -f utf16le -t utf8; }
utf16le() { iconv -f utf8 -t utf16le; }
check_params() {
    idx=0; for param in "$@"; do
	idx=$((idx+1)); [ -z "$param" ] && err "missing param #$idx"
    done
}

main "$@"
