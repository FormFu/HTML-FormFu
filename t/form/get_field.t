use strict;
use warnings;

use Test::More tests => 12;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

my $fs = $form->element('Fieldset');

my $e1 = $fs->element('Text')->name('foo');
my $e2 = $fs->element('Hidden')->name('foo');
my $e3 = $fs->element('Hidden')->name('bar');

{
    my @fields = $form->get_field;

    is( @fields, 1 );

    is( $fields[0], $e1 );

    ok( !@{ $e1->get_fields } );
}

{
    my @fields = $form->get_field( { type => 'Fieldset' } );

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
    my @fields = $form->get_field( { type => 'Hidden' } );

    is( @fields, 1 );

    is( $fields[0], $e2 );
}

{
    my @fields = $form->get_field( {
            name => 'foo',
            type => 'Hidden',
        } );

    is( @fields, 1 );

    is( $fields[0], $e2 );
}
