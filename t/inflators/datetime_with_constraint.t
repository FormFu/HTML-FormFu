use strict;
use warnings;

use Test::More tests => 5;

use HTML::FormFu;

my $form = HTML::FormFu->new;

# yaml config uses references to share the same parser spec between
# the constraint and inflator

$form->load_config_file('t/inflators/datetime_with_constraint.yml');

$form->process( { foo => '31-12-2006' } );

ok( $form->submitted_and_valid );

my $value = $form->params->{foo};

isa_ok( $value, 'DateTime' );

is( $value->day,   31 );
is( $value->month, 12 );
is( $value->year,  2006 );
