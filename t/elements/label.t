use strict;
use warnings;

use HTML::FormFu;
use Test::More tests => 3;

my $form = HTML::FormFu->new(
    { tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } } );

$form->load_config_file('t/elements/label.yml');

$form->process;

like( $form->get_field('foo'), qr/<span name="foo"><\/span>/, "element found" );

like(
    $form->get_field('foo3'),
    qr/<div name="foo3">bar<\/div>/,
    "element with value and different tag found"
);

$form->process( { submit => 'Submit Value', } );

like(
    $form->get_field('foo3'),
    qr/<div name="foo3">bar<\/div>/,
    "label retain_default works"
);
