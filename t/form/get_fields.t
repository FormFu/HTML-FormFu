use strict;
use warnings;

use Test::More tests => 19;

use HTML::FormFu;

my $form = HTML::FormFu->new;

my $fs = $form->element('Fieldset');

my $e1 = $fs->element('Text')->name('foo');
my $e2 = $fs->element('Hidden')->name('foo');
my $e3 = $fs->element('Hidden')->name('bar');

{
    my $fields = $form->get_fields;

    is( @$fields, 3 );

    ok( $fields->[0] == $e1 );
    ok( $fields->[1] == $e2 );
    ok( $fields->[2] == $e3 );

    ok( !@{ $e1->get_fields } );
    ok( !@{ $e2->get_fields } );
    ok( !@{ $e3->get_fields } );
}

{
    my $fields = $form->get_fields( { type => 'Fieldset' } );

    is( @$fields, 0 );
}

{
    my $fields = $form->get_fields('foo');

    is( @$fields, 2 );

    ok( $fields->[0] == $e1 );
    ok( $fields->[1] == $e2 );
}

{
    my $fields = $form->get_fields( { name => 'foo' } );

    is( @$fields, 2 );

    ok( $fields->[0] == $e1 );
    ok( $fields->[1] == $e2 );
}

{
    my $fields = $form->get_fields( { type => 'Hidden' } );

    is( @$fields, 2 );

    ok( $fields->[0] == $e2 );
    ok( $fields->[1] == $e3 );
}

{
    my $fields = $form->get_fields( {
            name => 'foo',
            type => 'Hidden',
        } );

    is( @$fields, 1 );

    ok( $fields->[0] == $e2 );
}
