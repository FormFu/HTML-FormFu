use strict;
use warnings;

use Test::More tests => 4;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->auto_fieldset( { nested_name => 'foo' } );

$form->element('Text')->name('bar')->constraint('DependOn')
    ->others(qw/ foo.baz foo.bag /);

$form->element('Text')->name('baz');
$form->element('Text')->name('bag');

# Valid
{
    $form->process({
        'foo.bar' => 1,
        'foo.baz' => 'a',
        'foo.bag' => [2],
    });

    ok( !$form->has_errors );
}

# Invalid
{
    $form->process( {
            'foo.bar' => 1,
            'foo.baz' => '',
            'foo.bag' => 2,
        } );

    ok( !$form->has_errors('foo.bar') );
    ok( $form->has_errors('foo.baz') );
    ok( !$form->has_errors('foo.bag') );
}

