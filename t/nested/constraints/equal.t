use strict;
use warnings;

use Test::More tests => 3;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->auto_fieldset( { nested_name => 'foo' } );

$form->element('Text')->name('bar')->constraint('Equal')->others('foo.baz');

$form->element('Text')->name('baz');

{
    $form->process({
        'foo.bar' => 'x',
        'foo.baz' => 'x',
    });

    ok( !$form->has_errors('foo.bar') );
    ok( !$form->has_errors );
}

{
    $form->process({
        'foo.bar' => 'x',
        'foo.baz' => 'y',
    });

    ok( !$form->has_errors('foo.bar') );
}
