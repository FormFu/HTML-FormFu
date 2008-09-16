use strict;
use warnings;

use Test::More tests => 2;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->load_config_file('t-aggregated/plugins/stashvalid_on_field.yml');

$form->process( {
        foo => 'a',
        bar => 'b',
    } );

is( $form->stash->{foo}, 'a' );
is( $form->stash->{bar}, undef );
