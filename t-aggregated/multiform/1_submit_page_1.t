use strict;
use warnings;

use Test::More tests => 2;

use HTML::FormFu::MultiForm;

my $multi = HTML::FormFu::MultiForm->new;

$multi->load_config_file('t-aggregated/multiform/multiform.yml');

$multi->process( {
        foo    => 'abc',
        submit => 'Submit',
    } );

my $form = $multi->current_form;

ok( $form->submitted_and_valid );

is_deeply(
    $form->params,
    {   foo    => 'abc',
        submit => 'Submit',
    } );
