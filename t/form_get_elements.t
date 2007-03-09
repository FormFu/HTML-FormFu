use strict;
use warnings;

use Test::More tests => 15;

use HTML::FormFu;

my $form = HTML::FormFu->new;

my $fs = $form->element('fieldset');

my $e1 = $fs->element('text')->name('foo');
my $e2 = $fs->element('hidden')->name('foo');
my $e3 = $fs->element('hidden')->name('bar');

{
    my $elems = $form->get_elements;

    is( @$elems, 1 );

    is( $elems->[0], $fs );
}

{
    my $elems = $form->get_elements( { type => 'fieldset' } );

    is( @$elems, 1 );

    is( $elems->[0], $fs );
}

{
    my $elems = $fs->get_elements('foo');

    is( @$elems, 2 );

    is( $elems->[0], $e1 );
    is( $elems->[1], $e2 );
}

{
    my $elems = $fs->get_elements( { name => 'foo' } );

    is( @$elems, 2 );

    is( $elems->[0], $e1 );
    is( $elems->[1], $e2 );
}

{
    my $elems = $fs->get_elements( { type => 'hidden' } );

    is( @$elems, 2 );

    is( $elems->[0], $e2 );
    is( $elems->[1], $e3 );
}

{
    my $elems = $fs->get_elements( {
            name => 'foo',
            type => 'hidden',
        } );

    is( @$elems, 1 );

    is( $elems->[0], $e2 );
}
