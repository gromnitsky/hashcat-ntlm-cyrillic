# hashcat-ntlm-cyrillic

A Cygwin helper for cracking NTLM passwords w/ hashcat.

## Why?

NTLM is `md4(utf16le(password))`. To crack it, you need to provide a
custom charset, converted to utf16le & presented in hex. This script
does the proper conversions automatically.

## Setup

~~~
$ git clone ...
$ cd hashcat-ntlm-cyrillic
$ wget https://hashcat.net/files/hashcat-5.1.0.7z
$ 7z x hashcat-5.1.0.7z
$ cd hashcat-5.1.0
~~~

winpty in PATH is advisable.

## Usage

Generate a hash for testing:

~~~
$ ../ntlm.sh hash кєк
af5fd3f79b88e5dca1a95238aa429e43
~~~

Crack it:

    ../ntlm.sh crack йцукенгшщзє af5fd3f79b88e5dca1a95238aa429e43

or

    ../ntlm.sh -l3 crack йцукенгшщзє af5fd3f79b88e5dca1a95238aa429e43

(You may pass any options to hashcat (like -d) *after* the hash
parameter.)

where -l3 is the length of a password, йцукенгшщзє is our charset. You
may provide file names instead of the charset & the hash. If you
provide a file name in place of the charset, its content must be
encoded as:

~~~
$ ../ntlm.sh mkcharset йцукенгшщзє
04333537393a3d4346484954
~~~

View the result:

~~~
$ ../ntlm.sh show af5fd3f79b88e5dca1a95238aa429e43
af5fd3f79b88e5dca1a95238aa429e43:кєк
~~~

## License

MIT
