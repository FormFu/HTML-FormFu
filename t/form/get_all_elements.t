use strict;
use warnings;

use Test::More tests => 25;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

my $fs = $form->element('Fieldset');

my $e1 = $fs->element('Text')->name('foo');
my $e2 = $fs->element('Hidden')->name('foo');
my $e3 = $fs->element('Hidden')->name('bar');

{
    my $elems = $form->get_all_elements;

    is( @$elems, 4 );

    is( $elems->[0], $fs );
    is( $elems->[1], $e1 );
    is( $elems->[2], $e2 );
    is( $elems->[3], $e3 );
}

{
    my $elems = $form->get_all_elements( { type => 'Fieldset' } );

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
    my $elems = $form->get_all_elements( { type => 'Hidden' } );

    is( @$elems, 2 );

    is( $elems->[0], $e2 );
    is( $elems->[1], $e3 );
}

{
    my $elems = $form->get_all_elements( {
            name => 'foo',
            type => 'Hidden',
        } );

    is( @$elems, 1 );

    is( $elems->[0], $e2 );
}
