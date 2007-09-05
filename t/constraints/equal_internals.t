use strict;
use warnings;

use Test::More tests => 5;

use HTML::FormFu::Constraint::Equal;

ok( HTML::FormFu::Constraint::Equal::_values_eq( '1',  '1' ) );
ok( HTML::FormFu::Constraint::Equal::_values_eq( ' ',  ' ' ) );
ok( HTML::FormFu::Constraint::Equal::_values_eq( 'aa', 'aa' ) );
ok( HTML::FormFu::Constraint::Equal::_values_eq( ['x'], ['x'] ) );
ok( HTML::FormFu::Constraint::Equal::_values_eq( [ 'a', 'b' ], [ 'b', 'a' ] ) );
