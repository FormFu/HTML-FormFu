use strict;
use warnings;

use Test::More tests => 25;

use HTML::FormFu;

my $form = HTML::FormFu->new;

my $fs = $form->element('fieldset');

my $e1 = $fs->element('text')->name('foo');
my $e2 = $fs->element('hidden')->name('foo');
my $e3 = $fs->element('hidden')->name('bar');

{
    my $elems = $form->get_all_elements;
    
    is( @$elems, 4 );

    is( $elems->[0], $fs );
    is( $elems->[1], $e1 );
    is( $elems->[2], $e2 );
    is( $elems->[3], $e3 );
}

{
    my $elems = $form->get_all_elements( { type => 'fieldset' } );

    is( @$elems, 1 );

    is( $elems->[0], $fs );

    my $fs_elems = $elems->[0]->get_all_elements;

    is( @$fs_elems, 3 );

    is( $fs_elems->[0], $e1 );
    is( $fs_elems->[1], $e2 );
    is( $fs_elems->[2], $e3 );

    my $e1_elems = $e1->get_all_elements;
    is( @$e1_elems, 0 );

    my $e2_elems = $e2->get_all_elements;
    is( @$e2_elems, 0 );

    my $e3_elems = $e3->get_all_elements;
    is( @$e3_elems, 0 );
}

{
    my $elems = $form->get_all_elements('foo');

    is( @$elems, 2 );

    is( $elems->[0], $e1 );
    is( $elems->[1], $e2 );
}

{
    my $elems = $form->get_all_elements( { name => 'foo' } );

    is( @$elems, 2 );

    is( $elems->[0], $e1 );
    is( $elems->[1], $e2 );
}

{
    my $elems = $form->get_all_elements( { type => 'hidden' } );

    is( @$elems, 2 );

    is( $elems->[0], $e2 );
    is( $elems->[1], $e3 );
}

{
    my $elems = $form->get_all_elements( {
            name => 'foo',
            type => 'hidden',
        } );

    is( @$elems, 1 );

    is( $elems->[0], $e2 );
}
