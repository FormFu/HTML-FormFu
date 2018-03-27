use strict;
use warnings;

use Test::More tests => 2;

use HTML::FormFu;

my $form = HTML::FormFu->new(
    { tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } } );

$form->load_config_file('t/bugs/multiple_checkbox_same_name.yml');

$form->process( { foo => [qw( 1 2 )], } );

my $foo = $form->get_fields('foo');

like( $foo->[0], qr/checked="checked"/ );
like( $foo->[1], qr/checked="checked"/ );
