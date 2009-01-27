use strict;
use warnings;

use Test::More tests => 2 + 1;
use Test::NoWarnings;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->element('Text');
$form->element('Text')->name('foo');

my $div = $form->element('Block');
$div->element('Text');
$div->element('Text')->name('bar');

$form->process( { foo => 1 } );

is( @{ $form->get_fields('foo') }, 1 );

{
    my $div = $form->get_element( { type => 'Block' } );

    is( @{ $div->get_fields('bar') }, 1 );
}
