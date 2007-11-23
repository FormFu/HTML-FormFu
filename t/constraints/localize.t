use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->element('Text')->name('foo');

$form->constraint('Required');

$form->constraint('Regex')->regex(qr/^\d+$/)
    ->message_loc('form_constraint_integer');

$form->process( { foo => 'a' } );

like( $form->get_field('foo'), qr/This field must be an integer/ );
