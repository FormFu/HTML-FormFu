use strict;
use warnings;

use Test::More tests => 3;

use HTML::FormFu;

my $form = HTML::FormFu->new->load_config_file(
    't/load_config_file_multi_stream.yml');

my ( $foo, $bar, $baz ) = @{ $form->get_fields };

ok( $foo->get_constraint );
ok( $bar->get_constraint );

# no constraint
ok( !$baz->get_constraint );

