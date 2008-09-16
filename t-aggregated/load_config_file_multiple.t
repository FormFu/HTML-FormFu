use strict;
use warnings;

use Test::More tests => 7;

use HTML::FormFu;

my $form
    = HTML::FormFu->new->load_config_file('t-aggregated/load_config_file_multiple.yml');

is( $form->action, '/foo' );

my $elems = $form->get_all_elements;

is( scalar @$elems, 3 );

is( $elems->[0]->type, 'Fieldset' );
is( $elems->[1]->type, 'Text' );
is( $elems->[2]->type, 'Text' );

is( $elems->[1]->name, 'foo' );
is( $elems->[2]->name, 'bar' );

