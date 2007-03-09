use strict;
use warnings;

use Test::More tests => 19;

use HTML::FormFu;

my $form = HTML::FormFu->new;

my $fs = $form->element('fieldset');

my $e1 = $fs->element('text')->name('foo');
my $e2 = $fs->element('hidden')->name('foo');
my $e3 = $fs->element('hidden')->name('bar');

{
    my $fields = $form->get_fields;

    is( @$fields, 3 );

    is( $fields->[0], $e1 );
    is( $fields->[1], $e2 );
    is( $fields->[2], $e3 );

    ok( !@{ $e1->get_fields } );
    ok( !@{ $e2->get_fields } );
    ok( !@{ $e3->get_fields } );
}

{
    my $fields = $form->get_fields( { type => 'fieldset' } );

    is( @$fields, 0 );
}

{
    my $fields = $form->get_fields('foo');

    is( @$fields, 2 );

    is( $fields->[0], $e1 );
    is( $fields->[1], $e2 );
}

{
    my $fields = $form->get_fields( { name => 'foo' } );

    is( @$fields, 2 );

    is( $fields->[0], $e1 );
    is( $fields->[1], $e2 );
}

{
    my $fields = $form->get_fields( { type => 'hidden' } );

    is( @$fields, 2 );

    is( $fields->[0], $e2 );
    is( $fields->[1], $e3 );
}

{
    my $fields = $form->get_fields( {
            name => 'foo',
            type => 'hidden',
        } );

    is( @$fields, 1 );

    is( $fields->[0], $e2 );
}
