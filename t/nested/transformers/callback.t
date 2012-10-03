use strict;
use warnings;

package CB;

sub cb2 {
    my $value = shift;

    $value =~ s/a/A/;

    return $value;
}

package main;

use Test::More tests => 3;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->auto_fieldset( { nested_name => 'foo' } );

$form->element('Text')->name('bar')->transformer('Callback')
    ->callback( \&CB::cb2 );
$form->element('Text')->name('baz')->transformer('Callback')
    ->callback("CB::cb2");

# Valid
{
    $form->process( {
            "foo.bar" => 1,
            "foo.baz" => [ 0, 'a', 'b' ],
        } );

    ok( $form->submitted_and_valid );

    is( $form->param('foo.bar'), 1 );

    is_deeply( [ $form->param('foo.baz') ], [ 0, 'A', 'b' ] );
}
