use strict;
use warnings;

use Test::More tests => 4;

use HTML::FormFu;

my $form = HTML::FormFu->new(
    { tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } } );

$form->load_config_file('t/bugs/error_multiple_fields_same_name.yml');

$form->process( { foo => [qw( 1 a )], } );

my @fields = @{ $form->get_fields };

ok( !@{ $fields[0]->get_errors } );
is( scalar( @{ $fields[1]->get_errors } ), 1 );

unlike( $fields[0], qr/This field must be an integer/i );
like( $fields[1], qr/This field must be an integer/i );
