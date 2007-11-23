use strict;
use warnings;

use Test::More tests => 3;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->element('Text')->name('foo')->constraint('Number');

ok( !$form->submitted_and_valid );

$form->process( { foo => 'a' } );

ok( !$form->submitted_and_valid );

$form->process( { foo => 1 } );

ok( $form->submitted_and_valid );
