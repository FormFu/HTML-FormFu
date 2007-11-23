use strict;
use warnings;

use Test::More tests => 1;

use lib 't/lib';
use HTML::FormFu;

my $form = HTML::FormFu->new( {
    localize_class => 'HTMLFormFu::I18N',
    tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' },
} );

$form->load_config_file('t/field_accessor_loc_arrayref.yml');

like( $form->get_field('foo'), qr|\Q<label>My one two args</label>| );
