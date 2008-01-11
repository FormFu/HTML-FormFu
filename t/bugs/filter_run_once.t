use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;

my $count = 0;

my $form = HTML::FormFu->new;

$form->element('Text')->name('foo');

$form->filter( Callback => 'foo' )->callback( sub { $count++ } );

$form->process( { foo => 'whatever', } );

is( $count, 1 );
