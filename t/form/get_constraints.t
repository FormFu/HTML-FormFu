use strict;
use warnings;

use Test::More tests => 17;

use HTML::FormFu;

my $form = HTML::FormFu->new;
my $fs   = $form->element('Fieldset');

$fs->element('Text')->name('name')->constraint('Word');
$fs->element('Text')->name('age')->constraint('Number');

$form->constraint( Required => 'name', 'age' );

{
    my $constraints = $form->get_constraints;

    is( @$constraints, 4 );

    is( $constraints->[0]->name, 'name' );
    is( $constraints->[1]->name, 'name' );
    is( $constraints->[2]->name, 'age' );
    is( $constraints->[3]->name, 'age' );

    is( $constraints->[0]->type, 'Word' );
    is( $constraints->[1]->type, 'Required' );
    is( $constraints->[2]->type, 'Number' );
    is( $constraints->[3]->type, 'Required' );
}

{
    my $constraints = $form->get_constraints('name');

    is( @$constraints, 2 );

    is( $constraints->[0]->type, 'Word' );
    is( $constraints->[1]->type, 'Required' );
}

{
    my $constraints = $form->get_constraints( { name => 'age' } );

    is( @$constraints, 2 );

    is( $constraints->[0]->type, 'Number' );
    is( $constraints->[1]->type, 'Required' );
}

{
    my $constraints = $form->get_constraints( { type => 'Number' } );

    is( @$constraints, 1 );

    is( $constraints->[0]->name, 'age' );
}
