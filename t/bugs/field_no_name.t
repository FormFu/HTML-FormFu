use strict;
use warnings;

use Test::More tests => 2 + 1;
use Test::NoWarnings;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->element('text');
$form->element('text')->name('foo');

my $div = $form->element('block');
$div->element('text');
$div->element('text')->name('bar');

$form->process({ foo => 1 });

is( @{ $form->get_fields('foo') }, 1 );

{
    my $div = $form->get_element( { type => 'block' } );

    is( @{ $div->get_fields('bar') }, 1 );
}
