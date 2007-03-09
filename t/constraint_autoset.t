use strict;
use warnings;

use Test::More tests => 2;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->element('select')
    ->name('foo')
    ->values([qw/ one two three /])
    ->constraint('AutoSet');

# Valid
{
    $form->process( {
            foo => 'two',
        } );

    ok( $form->valid('foo') );
}

# Invalid
{
    $form->process( {
            foo => 'yes',
        } );

    ok( $form->has_errors('foo') );
}
