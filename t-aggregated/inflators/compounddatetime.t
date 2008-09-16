use strict;
use warnings;

use Test::More tests => 7;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->load_config_file('t-aggregated/inflators/compounddatetime.yml');

$form->process({
    'dob.day'   => '31',
    'dob.month' => '12',
    'dob.year'  => '1999',
});

ok( $form->submitted_and_valid );

isa_ok( $form->param_value('dob'), 'DateTime' );

my $dob = $form->params->{dob};

isa_ok( $dob, 'DateTime' );

is( $dob->day,   '31' );
is( $dob->month, '12' );
is( $dob->year,  '1999' );

# check strptime

is( "$dob", "31-12-1999" );
