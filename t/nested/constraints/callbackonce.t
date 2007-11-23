use strict;
use warnings;

use Test::More tests => 5;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->auto_fieldset( { nested_name => 'foo' } );

$form->element('Text')->name('bar')->constraint('CallbackOnce')->callback(
    sub {
        ok(1);
        return 1;
    } );

$form->element('Text')->name('baz')->constraint('CallbackOnce')->callback(
    sub {
        ok(1);
        return 1;
    } );


$form->process({
    'foo.bar' => 'x',
    'foo.baz' => [1, 2],
});

ok( !$form->has_errors('foo.bar') );
ok( !$form->has_errors('foo.baz') );

ok( !$form->has_errors );

