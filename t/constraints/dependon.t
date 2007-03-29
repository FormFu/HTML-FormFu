use strict;
use warnings;

use Test::More tests => 4;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->element('text')->name('foo')->constraint('DependOn')->others(qw/ bar baz /);
$form->element('text')->name('bar');
$form->element('text')->name('baz');

# Valid
{
    $form->process( {
            foo => 1,
            bar => 'a',
            baz => [2],
        } );

    ok( !$form->has_errors );
}

# Invalid
{
    $form->process( {
            foo => 1,
            bar => '',
            baz => 2,
        } );

    ok( $form->valid('foo') );
    ok( $form->has_errors('bar') );
    ok( $form->valid('baz') );
}
