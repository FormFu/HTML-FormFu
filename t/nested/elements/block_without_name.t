use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->load_config_file('t/nested/elements/block_without_name.yml');

is( $form->get_field('bar')->nested_name, 'foo.bar' );

