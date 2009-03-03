use strict;
use warnings;

use Test::More tests => 5;

use HTML::FormFu::Model::HashRef;

my %test = (
    'name_2'       => 'name_2',
    'name_bar_foo' => 'name\\_bar\\_foo',
    'name_2_bar'   => 'name\\_2\\_bar',
    'name_2.bar'   => 'name_2.bar'
);

while ( my ( $k, $v ) = each %test ) {
    is( HTML::FormFu::Model::HashRef::_escape_name($k), $v );
}

is( HTML::FormFu::Model::HashRef::_unescape_name('foo\\_bar'), 'foo_bar' );
