use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;
use lib 't/lib';

my $form = HTML::FormFu->new(
    { tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } } );

$form->load_config_file('t-aggregate/roles/form.yml');

is( $form->custom_role_method, "form ID: xxx" );
