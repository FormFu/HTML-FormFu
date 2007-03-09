use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->element('text')->name('foo')->default('');

like( $form->get_field('foo'), qr/\Q value="" /x, 'empty value appears in XML' );

