use strict;
use warnings;

use Test::More tests => 4;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->element('Text')->name('name');
$form->element('Text')->name('age');

$form->constraint( Required => 'name', 'age' );
$form->constraint( Word   => 'name' );
$form->constraint( Number => 'age' );

{
    my @constraints = $form->get_constraint;

    is( @constraints, 1 );
}

{
    my @constraints = $form->get_constraint('name');

    is( @constraints, 1 );
}

{
    my @constraints = $form->get_constraint( { name => 'age' } );

    is( @constraints, 1 );
}

{
    my @constraints = $form->get_constraint( { type => 'Number' } );

    is( @constraints, 1 );
}
