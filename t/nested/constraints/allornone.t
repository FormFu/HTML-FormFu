use strict;
use warnings;

use Test::More tests => 5;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->indicator('submit');

$form->auto_fieldset( { nested_name => 'foo' } );

$form->element('Text')->name('bar')
    ->constraint('AllOrNone')->others('foo.baz');

$form->element('Text')->name('baz');

$form->element('Submit')->name('submit');

{
    $form->process({
        'foo.bar' => 'x',
        'foo.baz' => 'y',
        'submit'  => 'Submit',
    });

    ok( !$form->has_errors('foo.bar') );
    ok( !$form->has_errors );
}

{
    $form->process({
        'submit'  => 'Submit',
    });

    ok( !$form->has_errors('foo.bar') );
    ok( !$form->has_errors );
}

{
    $form->process({
        'foo.bar' => 'x',
        'submit'  => 'Submit',
    });

    ok( $form->has_errors('foo.baz') );
}
