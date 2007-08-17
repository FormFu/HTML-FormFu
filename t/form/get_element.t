use strict;
use warnings;

use Test::More tests => 12;

use HTML::FormFu;

my $form = HTML::FormFu->new;

my $fs = $form->element('Fieldset');

my $e1 = $fs->element('Text')->name('foo');
my $e2 = $fs->element('Hidden')->name('foo');
my $e3 = $fs->element('Hidden')->name('bar');

{
    my @elems = $form->get_element;

    is( @elems, 1 );

    is( $elems[0], $fs );
}

{
    my @elems = $form->get_element( { type => 'Fieldset' } );

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
    my @elems = $fs->get_element( { type => 'Hidden' } );

    is( @elems, 1 );

    is( $elems[0], $e2 );
}

{
    my @elems = $fs->get_element( {
            name => 'foo',
            type => 'Hidden',
        } );

    is( @elems, 1 );

    is( $elems[0], $e2 );
}
