use strict;
use warnings;

use Test::More tests => 2;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->load_config_file('t/internals/default_args-types.yml');

# default_args->{constraints} ISA ARRAY
# elements->[0]->{constraints} ISA HASH

my $field = $form->get_field('foo');

ok( $field->get_constraint({ type => 'Required' } ) );

ok( $field->get_constraint({ type => 'DateTime' } ) );
