use strict;
use warnings;

use Test::More tests => 12;

use HTML::FormFu;

my $form = HTML::FormFu->new;

my $fs = $form->element('fieldset');

my $e1 = $fs->element('text')->name('foo');
my $e2 = $fs->element('hidden')->name('foo');
my $e3 = $fs->element('hidden')->name('bar');

{
    my @elems = $form->get_element;

    is( @elems, 1 );

    is( $elems[0], $fs );
}

{
    my @elems = $form->get_element( { type => 'fieldset' } );

    is( @elems, 1 );

    is( $elems[0], $fs );
}

{
    my @elems = $fs->get_element('foo');

    is( @elems, 1 );

    is( $elems[0], $e1 );
}

{
    my @elems = $fs->get_element( { name => 'foo' } );

    is( @elems, 1 );

    is( $elems[0], $e1 );
}

{
    my @elems = $fs->get_element( { type => 'hidden' } );

    is( @elems, 1 );

    is( $elems[0], $e2 );
}

{
    my @elems = $fs->get_element( {
            name => 'foo',
            type => 'hidden',
        } );

    is( @elems, 1 );

    is( $elems[0], $e2 );
}
