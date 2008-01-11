use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->element('Text')->name('foo');

$form->constraint('Required');
$form->constraint('Regex')->regex(qr/^\d+$/)->message_xml("don't escape <me>");

$form->process( { foo => 'a' } );

like( $form->get_field('foo'), qr/don't escape <me>/ );
