use strict;
use warnings;

use Test::More tests => 2;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->element('Text')->name('foo');
$form->element('Text')->name('bar')
    ->auto_error_message('form_constraint_integer');

$form->constraint('Number');

$form->process( {
        foo => 'a',
        bar => 'b',
    } );

like( $form->get_field('foo'), qr!This field must be a number! );

like( $form->get_field('bar'), qr/integer/i );
