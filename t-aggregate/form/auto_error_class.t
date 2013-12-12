use strict;
use warnings;

use Test::More tests => 3;

use HTML::FormFu;

my $form = HTML::FormFu->new(
    { tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } } );

$form->element('Text')->name('foo');
$form->element('Text')->name('bar')->auto_error_class('form_%t_%s_error');

$form->constraint('Number');

$form->process( {
        foo => 'a',
        bar => 'b',
    } );

unlike( $form->get_field('foo'), qr/error/ );
like( $form->get_field('foo'), qr/This field must be a number/i );

like( $form->get_field('bar'), qr!\bform_number_constraint_error\b! );
