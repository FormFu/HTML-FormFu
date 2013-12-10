use strict;
use warnings;

use Test::More tests => 6;

use lib 't/lib';
use HTML::FormFu;

my $form = HTML::FormFu->new->localize_class('HTMLFormFu::I18N');

$form->element('Text')->name('foo');
$form->element('Text')->name('bar');

$form->validator('+HTMLFormFu::MyValidator');

# Valid
{
    $form->process( {
            foo => 'aaa',
            bar => 'bbbbbbb',
        } );

    ok( $form->valid('foo'), 'foo valid' );
    ok( $form->valid('bar'), 'bar valid' );
}

# Invalid
{
    $form->process( {
            foo => 'aaa',
            bar => 'foo',
        } );

    ok( $form->valid('foo'),  'foo valid' );
    ok( !$form->valid('bar'), 'bar not valid' );

    my ($error) = @{ $form->get_errors };

    is( $error->type,    'HTMLFormFu::MyValidator' );
    is( $error->message, 'myvalidator error!' );
}

