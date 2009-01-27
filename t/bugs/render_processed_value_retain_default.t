use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;
use DateTime;

my $form = HTML::FormFu->new(
    { tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } } );

$form->load_config_file('t/bugs/render_processed_value_retain_default.yml');

# set default

my $dt = DateTime->new(
    day => 7,
    month => 5,
    year => 2008,
);

$form->get_field('foo')->default($dt);

# don't submit foo

$form->process( {
    submit => 'Submit',
} );

# default is kept, and deflated
like( $form->get_field('foo')->render, qr|value="07/05/2008"| );
