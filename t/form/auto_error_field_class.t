use strict;
use warnings;

use Test::More tests => 3;

use HTML::FormFu;

my $form = HTML::FormFu->new(
    { tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } } );

$form->element('Text')->name('foo');
$form->element('Text')->name('bar')->auto_error_field_class('is-invalid');

$form->constraint('Number');

$form->process( {
        foo => 'a',
        bar => 'b',
    } );

unlike( $form->get_field('foo'), qr/error/ );
like( $form->get_field('foo'), qr/This field must be a number/i );

like( $form->get_field('bar'), qr!<input [^>]+ class="is-invalid"! );
