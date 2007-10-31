#!/usr/bin/perl
use strict;
use warnings;

use HTML::FormFu::Deploy;

warn <<END;
You only need to create a local copy of the HTML::FormFu template files
if you intend on customising them.
Otherwise, HTML::FormFu should automatically locate the system-wide copy of
the files, installed in the perl \@INC paths.

END

if ( @ARGV != 1 ) {
    die "ERROR: Target directory argument required\n";
}

HTML::FormFu::Deploy::deploy( $ARGV[0] );
