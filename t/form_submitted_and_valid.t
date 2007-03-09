use strict;
use warnings;

use Test::More tests => 3;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->element('text')->name('foo')->constraint('Number');

ok( !$form->submitted_and_valid );

$form->process({ foo => 'a' });

ok( !$form->submitted_and_valid );

$form->process({ foo => 1 });

ok( $form->submitted_and_valid );
