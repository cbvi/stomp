# stomp #

A commandline-based password manager writen in Perl 6 (and some Perl 5 using Inline::Perl5)

## Overview ##

stomp consists of two parts; stomp (the client) and stompd (the 'server')

All data is encrypted with a hash of the the stomp key, the stomp key itself
is encrypted with a hash of the master password entered by the user.

When started, stompd loads the encrypted key into memory. stomp can then send
the user's master password to unlock the key. Once unlocked, stomp can request
the plain-text of the key. This allows stomp to avoid asking for the master
password for every request, and without ever writing the unencrypted key to
disk.

The data for each site is stored in a separate file with a random filename. The
filename for each site is stored in the index file, which is encrypted. To find
which file contains the data for each site, stomp first reads the index file and
then reads the appropriate data file.

By default, stomp uses the following files:

    ~/.stomp
        index
        data/
        keys/
            stompkey

Encrypted data for each site is stored in the `data/` directory. The encrypted 
key is stored in the `keys/` directory and is called `stompkey`. The `index`
file is stored in the root `.stomp` directory and contains the encrypted index
data.

## Usage ##

    stomp add <sitename> <username>
    stomp get <sitename>
    stomp find <search term>
    stomp list
    stomp edit <sitename>
    stomp gen

## License ##

    Copyright (c) 2014 Carlin Bingham <cb@viennan.net>

    Permission to use, copy, modify, and distribute this software for any
    purpose with or without fee is hereby granted, provided that the above
    copyright notice and this permission notice appear in all copies.

    THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
    WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
    MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
    ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
    WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
    ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
    OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

## Again, for emphasis ##

    THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
    WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
    MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
    ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
    WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
    ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
    OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
