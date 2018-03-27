use strict;
use warnings;

# base the package name on the test file path
# to stop 'redefined' warnings under Test::Aggregate::Nested
package My::Nested::Validators::Callback;

sub cb {
    my $value  = shift;
    my $params = shift;
    ::ok(1) if grep { $value eq $_ ? 1 : 0 } qw/ 1 0 a /;
    ::ok( ref($params) eq 'HASH' && keys %$params, 'params hashref is passed' );
    return 1;
}

package main;

use Test::More tests => 11;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->auto_fieldset( { nested_name => 'foo' } );

$form->element('Text')->name('bar')->validator('Callback')
    ->callback( \&My::Nested::Validators::Callback::cb );

$form->element('Text')->name('baz');

# attached via form
$form->validator(
    {   type     => 'Callback',
        name     => 'foo.baz',
        callback => 'My::Nested::Validators::Callback::cb',
    } );

# Valid
{
    $form->process(
        {   'foo.bar' => 1,
            'foo.baz' => [ 0, 'a', 'b' ],
        } );

    ok( $form->valid('foo.bar') );
    ok( $form->valid('foo.baz') );

    is( $form->param('foo.bar'), 1 );

    is_deeply( [ $form->param('foo.baz') ], [ 0, 'a', 'b' ] );
}
