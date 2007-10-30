use strict;
use warnings;

use Test::More tests => 2;

use HTML::FormFu;

my $data = {
    a => 1,
    b => {
        c => 2,
        d => 3,
        },
    e => [ 4, 5 ],
    };

{
    my @names = HTML::FormFu::_hash_keys($data);
    @names = sort @names;

    is_deeply(
        \@names,
        [qw/
            a
            b.c
            b.d 
            e.0
            e.1
        /]
    );
}

{
    my @names = HTML::FormFu::_hash_keys( $data, 'subscript' );
    @names = sort @names;

    is_deeply(
        \@names,
        [qw/
            a
            b[c]
            b[d] 
            e[0]
            e[1]
        /]
    );
}

