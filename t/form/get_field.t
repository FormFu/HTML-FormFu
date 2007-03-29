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
    my @fields = $form->get_field;

    is( @fields, 1 );

    is( $fields[0], $e1 );

    ok( !@{ $e1->get_fields } );
}

{
    my @fields = $form->get_field( { type => 'fieldset' } );

    is( @fields, 0 );
}

{
    my @fields = $form->get_field('foo');

    is( @fields, 1 );

    is( $fields[0], $e1 );
}

{
    my @fields = $form->get_field( { name => 'foo' } );

    is( @fields, 1 );

    is( $fields[0], $e1 );
}

{
    my @fields = $form->get_field( { type => 'hidden' } );

    is( @fields, 1 );

    is( $fields[0], $e2 );
}

{
    my @fields = $form->get_field( {
            name => 'foo',
            type => 'hidden',
        } );

    is( @fields, 1 );

    is( $fields[0], $e2 );
}
