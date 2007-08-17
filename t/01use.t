use strict;
use warnings;

use Test::More tests => 3;

use_ok('HTML::FormFu');

use_ok('HTML::FormFu::Preload');

ok( $INC{'HTML/FormFu/Element/Text.pm'} );
