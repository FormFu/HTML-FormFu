use strict;
use warnings;

use Test::More tests => 2;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->load_config_file('t/nested/element_name.yml');

is( $form->get_field('bar')->nested_name, 'foo.bar' );

my $baz_fs = $form->get_element({ type => 'Fieldset' })
    ->get_element({ type => 'Block' });

is( $baz_fs->get_field('0')->nested_name, 'foo.baz.0' );
