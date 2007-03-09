use strict;
use warnings;

use Test::More tests => 5;

use HTML::FormFu::Constraint::Equal qw/ _values_eq /;

ok( _values_eq( '1',  '1' ) );
ok( _values_eq( ' ',  ' ' ) );
ok( _values_eq( 'aa', 'aa' ) );
ok( _values_eq( ['x'], ['x'] ) );
ok( _values_eq( [ 'a', 'b' ], [ 'b', 'a' ] ) );
