use strict;
use warnings;

use Test::More tests => 4;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->element('Text')->name('foo');

$form->constraint('JSON');

my @valid = ( '{"foo":"bar"}', '[1,2]', );

for my $string (@valid) {
    $form->process( { foo => $string, } );

    ok( $form->valid('foo'), "foo valid: $string" );
}

my @invalid = ( "{'foo':'bar'}", 'plain text', );

for my $string (@invalid) {
    $form->process( { foo => $string, } );

    ok( !$form->valid('foo'), "foo not valid: $string" );
}
