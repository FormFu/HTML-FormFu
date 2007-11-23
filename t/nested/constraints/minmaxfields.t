use strict;
use warnings;

use Test::More tests => 6;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->auto_fieldset( { nested_name => 'foo' } );

$form->element('Text')->name('bar')->constraint('MinMaxFields')
    ->others(qw/ foo.baz foo.bag foo.nod /)->min(1)->max(2);

$form->element('Text')->name('baz');
$form->element('Text')->name('bag');
$form->element('Text')->name('nod');

# Valid
{
    $form->process( {
            'foo.bar' => 1,
            'foo.baz' => '',
            'foo.bag' => [2],
            'foo.nod' => '',
        } );

    ok( !$form->has_errors );
}

# Valid
{
    $form->process( {
            'foo.bar' => 1,
            'foo.baz' => '',
            'foo.bag' => '',
            'foo.nod' => '',
        } );

    ok( !$form->has_errors );
}

# Invalid
{
    $form->process( {
            'foo.bar' => 1,
            'foo.baz' => 2,
            'foo.bag' => '',
            'foo.nod' => 22,
        } );

    ok( $form->has_errors('foo.bar') );
    ok( !$form->has_errors('foo.baz') );
    ok( !$form->has_errors('foo.bag') );
    ok( !$form->has_errors('foo.nod') );
}
